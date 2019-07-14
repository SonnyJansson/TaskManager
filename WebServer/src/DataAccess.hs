module DataAccess where

import Data.Aeson
import qualified Data.ByteString.Lazy as BS
import qualified Data.Text as T
import qualified Data.Text.IO as TIO
import Data.UUID

import Lucid

import System.Directory

import Text.Pandoc

import Types

projectsFile :: IO FilePath
projectsFile = return "./projects.json"

notesFile :: IO FilePath
notesFile = return "./notes.json"


getProjects :: IO (Maybe [Project])
getProjects = projectsFile >>= decodeFileStrict

getNotes :: IO (Maybe [Note])
getNotes = notesFile >>= decodeFileStrict


writeProjects :: [Project] -> IO ()
writeProjects projects = do
  filePath <- projectsFile
  encodeFile filePath projects

writeNotes :: [Note] -> IO ()
writeNotes notes = do
  putStrLn "Writing notes!"
  filePath <- notesFile
  encodeFile filePath notes


newNoteFile :: Note -> IO ()
newNoteFile note = do
  writeFile ("./notes/" ++ toString (noteUUID note) ++ fileFormatExtension (noteFormat note)) ""


getNoteHtml :: Note -> IO (Either PandocError (Html ())) -- PROBABLY MAKE IT SO THAT IT ALSO FEATURES OTHER FORMATS SUCH AS MARKDOWN AND WHATNOT SO THAT ONE IS FREE TO USE WHATEVER STYLE THEY ARE MOST COMFORTABLE WITH OR THAT IS MOST SUITABLE FOR THE TASK AT HAND
getNoteHtml note = do
  fileExists <- doesFileExist filePath
  if fileExists then do
    file <- TIO.readFile filePath
    runIO $ do
      doc <- readOrg def file
      fmap toHtmlRaw $ writeHtml5String def doc
  else return $ Right (toHtml "That note does not exist")
    where
      filePath = "./notes/" ++ (show . noteUUID) note ++ (fileFormatExtension . noteFormat) note

fileFormatRead :: PandocMonad m => FileFormat -> ReaderOptions -> T.Text -> m Pandoc
fileFormatRead Org = readOrg
fileFormatRead Markdown = readMarkdown

fileFormatExtension :: FileFormat -> String
fileFormatExtension Org = ".org"
fileFormatExtension Markdown = ".md"


-- INCLUDE A SIMPLE IN-BROWSER EDITOR JUST IN CASE EDITS NEED TO BE MADE ON THE FLY

-- MAYBE INCLUDE A PERSONAL IMAGE OR ASSET LIBRARY SO THERE IS SOMEWHERE TO STORE THOSE
