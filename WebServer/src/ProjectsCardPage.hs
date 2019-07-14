{-# LANGUAGE OverloadedStrings, ExtendedDefaultRules, DuplicateRecordFields #-}

module ProjectsCardPage where

import Control.Monad
import Data.List
import Data.Semigroup
import qualified Data.Text as T

import Lucid

import PageCommons
import Types

projectCardsPage :: [Project] -> Html ()
projectCardsPage = page content

content :: [Project] -> Html ()
content projects = do
  div_ [id_ "content", class_ "w-100"] $
    div_ [class_ "container-fluid"] $ do
      div_ [class_ "row"] $
        nav_ [class_ "col-12 navbar navbar-expand-lg sticky-top navbar-light border-bottom"] $ do
          button_ [type_ "button", id_ "sidebarCollapse", class_ "btn btn-info bg-dark"] $ do
            i_ [class_ "fas fa-bars"] ""
            --span_ "Toggle Sidebar"

          div_ [class_ "nav-item ml-auto"] $
            return ()
      when (not $ null projects) searchbar
      projectCards projects

searchbar :: Html ()
searchbar = do
  div_ [class_ "row"] $
    div_ [class_ "search col-lg-l4 col-md-6 col-sm-6 col-xs-12"] $
      input_ [type_ "text", class_ "form-control", placeholder_ "Search"]

projectCards :: [Project] -> Html ()
projectCards projects = do
  div_ [class_ "row"] $
    mapM_ projectToCard projects

projectToCard :: Project -> Html ()
projectToCard project = do
  div_ [class_ "col-xl-3 col-lg-4 col-md-6 col-sm-6"] $
    div_ [class_ "card projectCard", style_ "width: 18rem;"] $
      div_ [class_ "card-body"] $ do
        h5_ [class_ "card-title"] (toHtml $ projectName project)
        p_ [class_ "card-text overflow-hidden"] (toHtml $ projectDescription project)
        a_ [href_ ("/p/" <> projectName project), class_ "btn btn-primary"] "Open Project"
