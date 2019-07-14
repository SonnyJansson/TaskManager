{-# LANGUAGE OverloadedStrings, ExtendedDefaultRules, DuplicateRecordFields #-}

module HomePage where

import Control.Monad
import Data.List
import Data.Semigroup
import qualified Data.Text as T

import Lucid

import PageCommons
import Types

homePage :: Html ()
homePage = page content ()

content :: () -> Html ()
content _ = do
  div_ [id_ "content", style_ "width: 100%"] $
    div_ [class_ "container-fluid"] $
      div_ [class_ "row"] $
        nav_ [class_ "col-12 p-0"] $ 
          ul_ [class_ "list-group list-group-flush"] $ do
            li_ [class_ "homePageButton w-100 list-group-item list-group-item-action pl-3 pr-0"] $
              a_ [href_ "/projects", class_ "w-100", style_ "display: inline-block; text-decoration: none;"] $
                div_ [class_ "d-flex w-100 justify-content-between"] $
                  h1_ [class_ "text-dark"] $ do 
                    i_ [class_ "h-100 fas fa-th-large text-primary pr-3"] ""
                    "Projects"
            li_ [class_ "homePageButton w-100 list-group-item list-group-item-action pl-3 pr-0"] $
              a_ [href_ "/calendar", class_ "w-100", style_ "display: inline-block; text-decoration: none;"] $
                div_ [class_ "d-flex w-100 justify-content-between"] $
                  h1_ [class_ "text-dark"] $ do
                    i_ [class_ "h-100 far fa-calendar-alt text-danger pr-3"] ""
                    "Calendar"
            li_ [class_ "homePageButton w-100 list-group-item list-group-item-action pl-3 pr-0"] $
              h1_ "Deja vu..."
