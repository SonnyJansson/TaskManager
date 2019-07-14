{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE OverloadedStrings #-}

module Types where

import Data.Aeson
import Data.IORef
import qualified Data.Text as T
import Data.UUID
  
import GHC.Generics

import Lucid

type HtmlIO = HtmlT IO

-- PROJECT --

data Project = Project 
             { projectName        :: T.Text
             , projectDescription :: T.Text

             , projectFinished    :: Bool
             , projectImportant   :: Bool

             , goals              :: [Goal]
             } deriving (Generic, Show)

instance ToJSON Project
instance FromJSON Project

data Goal = Goal
          { goalName        :: T.Text
          , goalDescription :: T.Text 
          , goalID          :: GoalID

          , goalFinished    :: Bool
          , goalImportant   :: Bool
          , goalCollapsed   :: Bool

          , subGoals        :: [Goal]
          } deriving (Generic, Show)

instance ToJSON Goal
instance FromJSON Goal

type GoalID = [Int]

-- NOTES --

data FileFormat = Org | Markdown deriving (Generic, Show)

instance ToJSON FileFormat
instance FromJSON FileFormat

data Note = Note
          { noteUUID      :: UUID
          , noteName      :: T.Text
          , noteOutline   :: T.Text
          , noteFormat    :: FileFormat
          } deriving (Generic)

instance ToJSON Note
instance FromJSON Note

data NoteCreateRequest = NoteCreateRequest
                       { newNoteName   :: T.Text
                       , newNoteFormat :: FileFormat
                       , newNoteTags   :: T.Text
                       } deriving (Generic, Show)

instance ToJSON NoteCreateRequest
instance FromJSON NoteCreateRequest

-- APP STATE --

type AppState = IORef InternalAppState

data InternalAppState = InternalAppState
                      { projects :: [Project]
                      , notes    :: [Note]
                      }
