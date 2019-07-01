{-# LANGUAGE OverloadedStrings, ExtendedDefaultRules, DuplicateRecordFields #-}

module ProjectPage where

import Control.Monad
import Data.List
import Data.Semigroup
import qualified Data.Text as T

import Lucid

data Project = Project 
             { projectName        :: T.Text
             , projectDescription :: T.Text

             , projectFinished    :: Bool
             , projectImportant   :: Bool

             , goals              :: [Goal]
             }

data Goal = Goal
          { goalName        :: T.Text
          , goalDescription :: T.Text 
          , goalID          :: GoalID

          , goalFinished    :: Bool
          , goalImportant   :: Bool
          , goalCollapsed   :: Bool

          , subGoals        :: [Goal]
          }

type GoalID = [Int]

goal1 = Goal
      { goalName = "Do this thing!"
      , goalDescription = "So, I want you to do this thing"
      , goalID = [1]
      , goalFinished = False
      , goalImportant = False
      , goalCollapsed = False
      , subGoals = [goal1_1]
      }

goal1_1 = Goal
        { goalName = "Do this thing!"
        , goalDescription = "So, I want you to do this thing"
        , goalID = [1,1]
        , goalFinished = False
        , goalImportant = False
        , goalCollapsed = False
        , subGoals = []
        }

goal2 = Goal
      { goalName = "Do this thing!"
      , goalDescription = "So, I want you to do this thing"
      , goalID = [2]
      , goalFinished = False
      , goalImportant = False
      , goalCollapsed = False
      , subGoals = [goal2_1]
      }
  
goal2_1 = Goal
        { goalName = "Do this thing!"
        , goalDescription = "So, I want you to do this thing"
        , goalID = [2,1]
        , goalFinished = False
        , goalImportant = False
        , goalCollapsed = False
        , subGoals = []
        }

testProject = Project 
            { projectName = "Test Project"
            , projectDescription = "Wow, what a cool project!"
            , projectFinished = False
            , projectImportant = False
            , goals = [goal1, goal2]
            }

projectPage :: Html ()
projectPage = do
  html_ [lang_ "en"] $ do
    head_ $ do
      meta_ [name_ "viewport", content_ "width=device-width, initial-scale=1, shrink-to-fit=no"]
      link_ [rel_ "stylesheet", href_ "https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/css/bootstrap.min.css", integrity_ "sha384-ggOyR0iXCbMQv3Xipma34MD+dH/1fQ784/j6cY/iJTQUOhcWr7x9JvoRxT2MZw1T", crossorigin_ "anonymous"]
      link_ [rel_ "stylesheet", href_ "https://use.fontawesome.com/releases/v5.8.1/css/all.css", integrity_ "sha384-50oBUHEmvpQ+1lW4y57PTFmhCaXp0ML5d60M1M7uH2+nqUivzIebhndOJK28anvf", crossorigin_ "anonymous"]
      link_ [rel_ "stylesheet", type_ "text/css", href_ "mycss.css"]
    
    body_ $
      div_ [class_ "wrapper"] $ do
        sidebar
        content
        scripts

sidebar :: Html ()
sidebar = do
  nav_ [id_ "sidebar"] $ do
    div_ [class_ "sidebar-header"] $ do
      h3_ "Bootstrap Sidebar"

    div_ [class_ "list-group"] $ do
      a_ [href_ "#", class_ "menuItem list-group-item rounded-0"] "Item 1"
      a_ [href_ "#", class_ "menuItem list-group-item rounded-0"] "Item 2"

content :: Html ()
content = do
  div_ [id_ "content", style_ "width: 100%"] $
    div_ [class_ "container-fluid"] $ do
      div_ [class_ "row"] $
        nav_ [class_ "col-12 navbar navbar-expand-lg navbar-light bg_light"] $
          div_ [class_ "container-fluid"] $
            button_ [type_ "button", id_ "sidebarCollapse", class_ "btn btn-info"] $ do
              i_ [class_ "fas fa-align-left"] ""
              span_ "Toggle Sidebar"
      div_ [class_ "row"] $
        div_ [class_ "col-12"] $ do
          projectToHtml testProject

  div_ [class_ "overlay"] ""


projectToHtml :: Project -> Html ()
projectToHtml project = do
  div_ $
    h1_ $ do
      span_ [class_ "goalCounter badge badge-primary m-1", style_ "float: right;", id_ "goalCounterOverall"]
            (toHtml $ (T.pack . show . finishedAmount . goals) project <> T.pack "/" <> (T.pack . show . length . goals) project)
      toHtml $ projectName project

  hr_ [class_ "goalSeparator"]

  div_ [class_ "list-group projectGoalList", id_ "listOverall"] $
    goalsToHtml (goals project)

goalsToHtml :: [Goal] -> Html ()
goalsToHtml goals = do
  sequence_ $ intersperse (hr_ [class_ "goalSeparator active"]) $ fmap goalToHtml goals

goalToHtml :: Goal -> Html ()
goalToHtml goal = do
  div_ [class_ "list-group-item border-0 projectGoal"] $ do
    div_ [class_ "checkboxDiv custom-control custom-checkbox"] $ do
      input_ [type_ "checkbox", class_ "custom-control-input", id_ (T.pack "goalCheck" <> goalIDText goal)]
      label_ [class_ "checkboxLabel custom-control-label", Lucid.for_ (T.pack "goalCheck" <> goalIDText goal)]
             (toHtml $ goalName goal)

      div_ [class_ "float-right"] $ do
        when (hasSubGoals goal) $ do
          i_ [class_ "fas fa-chevron-down goalExpand mr-2", onclick_ ("toggleExpand('" <> goalIDText goal <> "')"), id_ ("expand" <> goalIDText goal)] ""
        i_ [class_ "fas fa-flag goalFlag", onclick_ ("toggleImportant('" <> goalIDText goal <> "')"), id_ ("flag" <> goalIDText goal)] ""

      div_ [id_ ("attributes" <> goalIDText goal)] $ do
        when (not (null $ subGoals goal)) $ do
          span_ [class_ "goalCounter badge badge-primary", id_ ("goalCount" <> goalIDText goal)]
                (toHtml $ (T.pack . show . finishedAmount . subGoals) goal <> T.pack "/" <> (T.pack . show . length . subGoals) goal)
        div_ [class_ "badge badge-pill badge-warning important", id_ ("important" <> goalIDText goal)]
             "Important!"

    when (hasSubGoals goal) $ do
      hr_ [class_ "goalSeparator active", id_ ("subGoalSeparator" <> goalIDText goal)]
      div_ [class_ "list-group goalList active", id_ ("subList" <> goalIDText goal)] $
        goalsToHtml (subGoals goal)

scripts :: Html ()
scripts = do
  script_ [src_ "https://code.jquery.com/jquery-3.3.1.slim.min.js", integrity_ "sha384-q8i/X+965DzO0rT7abK41JStQIAqVgRVzpbzo5smXKp4YfRvH+8abtTE1Pi6jizo", crossorigin_ "anonymous"] ""
  script_ [src_ "https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.7/umd/popper.min.js", integrity_ "sha384-UO2eT0CpHqdSJQ6hJty5KVphtPhzWj9WO1clHTMGa3JDZwrnQq4sF86dIHNDz0W1", crossorigin_ "anonymous"] ""
  script_ [src_ "https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/js/bootstrap.min.js", integrity_ "sha384-JjSmVgyd0p3pXB1rRibZUAYoIIy6OrQ6VrjIEaFf/nJGzIxFDsf4x0xIM+B07jRM", crossorigin_ "anonymous"] ""
  script_ [src_ "index.js"] ""
        

finishedAmount :: [Goal] -> Int
finishedAmount = length . filter goalFinished

goalIDText :: Goal -> T.Text
goalIDText = goalIDToText . goalID

goalIDToText :: GoalID -> T.Text
goalIDToText = T.pack . join . intersperse "_" . fmap show

-- Probably add top and bottom margins of the top part of the project as well as possibly change the background colour to a slightly darker shade of grey

{-

          div_ $
            h1_ $ do
              span_ [class_ "goalCounter badge badge-primary m-1", style_ "float: right;", id_ "goalCounterOverall"] "0/2"
              "Project Thingy"
          
          hr_ [class_ "goalSeparator"]

          div_ [class_ "list-group projectGoalList", id_ "listOverall"] $
            div_ [class_ "list-group-item border-0 projectGoal"] $ do
              div_ [class_ "checkBoxDiv custom-control custom-checkbox"] $ do
                input_ [type_ "checkbox", class_ "custom-control-input", id_ "goalCheck1"]
                label_ [class_ "checkBoxLabel custom-control-label", for_ "goaLCheck1"] "Maybe this piece of shit will work now"
              div_ [class_ "float-right"] $ do
                i_ [class_ "fas fa-chevron-down goalExpand mr-2", onclick_ "toggleExpand('1')", id_ "expand1"] ""
                i_ [class_ "fas fa-flag goalFlag", onclick_ "toggleImportant('1')", id_ "flag1"] ""

-}

hasSubGoals :: Goal -> Bool
hasSubGoals = not . null . subGoals