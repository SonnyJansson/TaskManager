{-# LANGUAGE OverloadedStrings #-}

module Main where

import Web.Spock
import Web.Spock.Config

import Control.Monad.Trans
import Control.Lens (set, (.~))

import Data.Function
import Data.HVect
import Data.IORef
import Data.Monoid
import qualified Data.Text as T

import Web.Spock.Lucid (lucid)
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

import ProjectPage

data Session = EmptySession
data AppState = AppState
              { 
              }

app :: SpockM () Session AppState ()
app = do 
  get root $ lucid projectPage
  get (root <//> "mycss.css") $ file "mycss" "./mycss.css"
  get (root <//> "index.js") $ file "index" "./index.js"
  get (root <//> "hello") $ lucid $ do 
    h1_ ("Hello, ")

{-
main :: IO ()
main = do
  cfg <- defaultSpockCfg EmptySession PCNoDatabase EmptyAppState
  runSpock 8080 (spock cfg app)
-}

main :: IO ()
main = do
  setEnv "AWS_ACCESS_KEY_ID" "AKIAJYFHD4MGQYFMJYLQ"
  setEnv "AWS_SECRET_ACCESS_KEY_ID" "fY2AX5QA1HBQSGZkNflOrPXIf/zUwKJvWf6t7qI0"

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