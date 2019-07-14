{-# LANGUAGE OverloadedStrings, ExtendedDefaultRules, DuplicateRecordFields #-}

module ProjectPage where

import Control.Monad
import Data.List
import Data.Semigroup
import qualified Data.Text as T

import Lucid

import PageCommons
import Types

testProject = Project 
            { projectName = "Test Project"
            , projectDescription = "Wow, what a cool project!"
            , projectFinished = False
            , projectImportant = False
            , goals = []
            }

projectPage :: Project -> Html ()
projectPage = page content

content :: Project -> Html ()
content project = do
  div_ [id_ "content", style_ "width: 100%"] $
    div_ [class_ "container-fluid"] $ do
      div_ [class_ "row"] $
        nav_ [class_ "col-12 navbar navbar-expand-lg sticky-top navbar-light border-bottom"] $ do
          button_ [type_ "button", id_ "sidebarCollapse", class_ "btn btn-info bg-dark"] $ do
            i_ [class_ "fas fa-bars"] ""
            --span_ "Toggle Sidebar"

          div_ [class_ "nav-item ml-auto"] $
            return ()
      div_ [class_ "row"] $
        div_ [class_ "col-12"] $ do
          projectToHtml project

  --div_ [class_ "overlay"] ""

projectToHtml :: Project -> Html ()
projectToHtml project = do
  div_ [id_ "project"] $
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
      input_ [type_ "checkbox", class_ ("custom-control-input goalCheckbox " <> if goalFinished goal then "checked" else ""), id_ (T.pack "goalCheck" <> goalIDText goal), onclick_ ("toggleCheck('" <> goalIDText goal <> "')")]
      label_ [class_ "checkboxLabel custom-control-label", Lucid.for_ (T.pack "goalCheck" <> goalIDText goal)]
             (toHtml $ goalName goal)

      div_ [class_ "float-right"] $ do
        when (hasSubGoals goal) $ do
          i_ [class_ "fas fa-chevron-down goalExpand mr-2", onclick_ ("toggleExpand('" <> goalIDText goal <> "')"), id_ ("expand" <> goalIDText goal)] ""
        i_ [class_ ("fas fa-flag goalFlag mr-2 " <> if goalImportant goal then "active" else ""), onclick_ ("toggleImportant('" <> goalIDText goal <> "')"), id_ ("flag" <> goalIDText goal)] ""
        i_ [class_ "fas fa-plus goalAdd"] ""

      div_ [id_ ("attributes" <> goalIDText goal)] $ do
        when (not (null $ subGoals goal)) $ do
          span_ [class_ "goalCounter badge badge-primary", id_ ("goalCount" <> goalIDText goal)]
                (toHtml $ (T.pack . show . finishedAmount . subGoals) goal <> T.pack "/" <> (T.pack . show . length . subGoals) goal)
        div_ [class_ ("badge badge-pill badge-warning important " <> if goalImportant goal then "active" else ""), id_ ("important" <> goalIDText goal)]
             "Important!"

    when (hasSubGoals goal) $ do
      hr_ [class_ "goalSeparator active", id_ ("subGoalSeparator" <> goalIDText goal)]
      div_ [class_ "list-group goalList active", id_ ("subList" <> goalIDText goal)] $
        goalsToHtml (subGoals goal)

finishedAmount :: [Goal] -> Int
finishedAmount = length . filter goalFinished

goalIDText :: Goal -> T.Text
goalIDText = goalIDToText . goalID

goalIDToText :: GoalID -> T.Text
goalIDToText = T.pack . join . intersperse "_" . fmap show

hasSubGoals :: Goal -> Bool
hasSubGoals = not . null . subGoals

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
