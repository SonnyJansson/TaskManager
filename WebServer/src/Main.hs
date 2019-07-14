{-# LANGUAGE OverloadedStrings #-}

module Main where

import Web.Spock
import Web.Spock.Config

import Control.Monad.Trans
import Control.Lens (set, (.~))

import Data.Aeson hiding (json)
import Data.Function
import Data.HVect
import Data.IORef
import Data.List
import Data.Monoid
import qualified Data.Text as T
import Data.UUID
import Data.UUID.V4

import Web.Spock.Lucid (lucid, lucidIO)
import Lucid

import Network.Wai.Middleware.Static

-- Imports required for database access

import Network.AWS
import Network.AWS.DynamoDB

import System.Environment (setEnv)
import System.IO (stdout)

import Database.DynamoDB
import Database.DynamoDB.Filter
import Database.DynamoDB.Update

--

import DataAccess
import HomePage
import NotesPage
import ProjectsCardPage
import ProjectPage
import Types

data Session = EmptySession

app :: SpockM () Session AppState ()
app = do 
  get (root <//> "testinit") $ do
    stateWriteNotes [testNote]
    liftIO $ writeNotes [testNote]
  
  get root $ lucid $ homePage

  get (root <//> "projects") $ do
    projects <- stateGetProjects
    lucid $ projectCardsPage projects

  get (root <//> "p" <//> var <//> "structure.json") $ \name -> do
    projects <- stateGetProjects
    json $ case find ((==) name . projectName) projects of
      Just project -> project
      Nothing      -> testProject

  get (root <//> "p" <//> var) $ \name -> do
    projects <- stateGetProjects
    lucid $ projectPage $ case find ((==) name . projectName) projects of
      Just project -> project
      Nothing      -> testProject

  get (root <//> "notelist.json") $ do -- This actually doesn't need to get sent, the UUID could be embedded in an ID in the HTML
    notes <- stateGetNotes
    json notes

  get (root <//> "notes") $ do
    notes <- stateGetNotes
    lucidIO $ notesPage notes

  get (root <//> "note" <//> var) $ \uuid -> do
    notes <- stateGetNotes
    noteHtml <- liftIO $ case find ((==) uuid . noteUUID) notes of
      Just note -> getNoteHtml note
      Nothing   -> return $ Right $ h1_ "That note could not be found"
    lucid $ case noteHtml of
      Left error -> do
        h1_ "Note could not be compiled to HTML"
        p_ (toHtml $ show error)
      Right html -> html

  get (root <//> "mycss.css") $ file "mycss" "./mycss.css"
  get (root <//> "index.js") $ file "index" "./index.js"
  get (root <//> "hello") $ lucid $ do 
    h1_ ("Hello, ")

  post (root <//> "projectStructure") $ do
    maybeResponse <- jsonBody :: (MonadIO m) => ActionCtxT ctx m (Maybe Project)
    case maybeResponse of
      Just project -> do
        stateWriteProjects [project]
        liftIO $ putStrLn $ show project
      Nothing   -> liftIO $ putStrLn $ show "Could not parse JSON in POST request (project structure change)"

  post (root <//> "newPost") $ do
    maybeResponse <- jsonBody :: (MonadIO m) => ActionCtxT ctx m (Maybe NoteCreateRequest)
    case maybeResponse of
      Just noteCreateRequest -> do
        --stateWriteProjects [project]
        liftIO $ putStrLn $ show noteCreateRequest
        uuid <- liftIO nextRandom 
        let note = Note {noteName = newNoteName noteCreateRequest, noteUUID = uuid, noteOutline = "Random junk", noteFormat = newNoteFormat noteCreateRequest}
        stateAddNote note
        liftIO $ newNoteFile note
        notes <- stateGetNotes
        liftIO $ writeNotes notes
        redirect "/notes"
      Nothing   -> liftIO $ putStrLn $ show "Could not parse JSON in POST request (project structure change)"


testNote :: Note
testNote = Note
         { noteUUID = case fromString "c2cc10e1-57d6-4b6f-9899-38d972112d8c" of
             Just uuid -> uuid
             Nothing   -> nil
         , noteName = T.pack "Test Note"
         , noteOutline = T.pack "Pretty cool test note"
         , noteFormat = Org
         }
  
--stateGetProjects :: SpockCtxM ctx conn sess AppState [Project]
stateGetProjects = do
  ref <- getState
  (liftIO . fmap projects . readIORef) ref

stateGetNotes = do
  ref <- getState
  (liftIO . fmap notes . readIORef) ref

stateWriteProjects :: [Project] -> ActionCtxT () (WebStateM () Session AppState) ()
stateWriteProjects projects = do
  ref <- getState
  liftIO $ modifyIORef ref (\s -> s {projects = projects})

stateWriteNotes :: [Note] -> ActionCtxT () (WebStateM () Session AppState) ()
stateWriteNotes notes = do
  ref <- getState
  liftIO $ modifyIORef ref (\s -> s {notes = notes})

stateAddNote :: Note -> ActionCtxT () (WebStateM () Session AppState) ()
stateAddNote note = do
  ref <- getState
  liftIO $ modifyIORef ref (\s -> s {notes = note:(notes s)})

main :: IO ()
main = do
  appState <- loadAppState
  cfg <- defaultSpockCfg EmptySession PCNoDatabase appState
  runSpock 8080 (spock cfg app)

loadAppState :: IO AppState
loadAppState = do
  projectsMaybe <- getProjects
  notesMaybe    <- getNotes
  --InternalAppState <$> projectsMaybe <*> notesMaybe

  let projects = case projectsMaybe of
                   Just p  -> p
                   Nothing -> []
  
  let notes = case notesMaybe of
                Just n  -> n
                Nothing -> []

  newIORef $ InternalAppState {projects = projects, notes = notes}

{-
main :: IO ()
main = do
  setEnv "AWS_ACCESS_KEY_ID"
  setEnv "AWS_SECRET_ACCESS_KEY_ID"

  lgr <- newLogger Info stdout
  env <- newEnv Discover

  -- Maybe change first argument to True (enables HTTPS instead of HTTP)
  let dynamo = setEndpoint False "dynamodb.us-east-2.amazonaws.com" 8000 dynamoDB
  let newenv = env & configure dynamo
                   & set envLogger lgr

  runResourceT $ runAWS newenv $ do
    return ()

  putStrLn "Hello!"

  return ()
-}
