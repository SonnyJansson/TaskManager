{-# LANGUAGE OverloadedStrings, ExtendedDefaultRules, DuplicateRecordFields #-}

module PageCommons where

import Control.Monad
import Data.List
import Data.Semigroup
import qualified Data.Text as T

import Lucid

import Types

page :: Monad m => (a -> HtmlT m ()) -> a -> HtmlT m ()
page content state = do
  html_ [lang_ "en"] $ do
    head_ $ do
      meta_ [name_ "viewport", content_ "width=device-width, initial-scale=1, shrink-to-fit=no"]
      link_ [rel_ "stylesheet", href_ "https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/css/bootstrap.min.css", integrity_ "sha384-ggOyR0iXCbMQv3Xipma34MD+dH/1fQ784/j6cY/iJTQUOhcWr7x9JvoRxT2MZw1T", crossorigin_ "anonymous"]
      link_ [rel_ "stylesheet", href_ "https://use.fontawesome.com/releases/v5.8.1/css/all.css", integrity_ "sha384-50oBUHEmvpQ+1lW4y57PTFmhCaXp0ML5d60M1M7uH2+nqUivzIebhndOJK28anvf", crossorigin_ "anonymous"]
      link_ [rel_ "stylesheet", type_ "text/css", href_ "/mycss.css"]
      link_ [rel_ "stylesheet", href_ "https://fonts.googleapis.com/css?family=Lato&display=swap"]
    
    body_ $
      div_ [class_ "wrapper"] $ do
        sidebar
        content state
        scripts

sidebar :: Monad m => HtmlT m ()
sidebar = do
  nav_ [id_ "sidebar"] $ do
    div_ [class_ "sidebar-header"] $ do
      h3_ "Bootstrap Sidebar"

    div_ [class_ "list-group"] $ do
      a_ [href_ "/projects", class_ "menuItem list-group-item rounded-0"] "Projects"
      a_ [href_ "/notes", class_ "menuItem list-group-item rounded-0"] "Notes"

scripts :: Monad m => HtmlT m ()
scripts = do
  script_ [src_ "https://ajax.googleapis.com/ajax/libs/jquery/3.4.1/jquery.min.js"] ""
  --script_ [src_ "https://code.jquery.com/jquery-3.3.1.slim.min.js", integrity_ "sha384-q8i/X+965DzO0rT7abK41JStQIAqVgRVzpbzo5smXKp4YfRvH+8abtTE1Pi6jizo", crossorigin_ "anonymous"] ""
  script_ [src_ "https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.7/umd/popper.min.js", integrity_ "sha384-UO2eT0CpHqdSJQ6hJty5KVphtPhzWj9WO1clHTMGa3JDZwrnQq4sF86dIHNDz0W1", crossorigin_ "anonymous"] ""
  script_ [src_ "https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/js/bootstrap.min.js", integrity_ "sha384-JjSmVgyd0p3pXB1rRibZUAYoIIy6OrQ6VrjIEaFf/nJGzIxFDsf4x0xIM+B07jRM", crossorigin_ "anonymous"] ""
  script_ [src_ "/index.js"] ""


--navbar :: Monad m => HtmlT m () -> HtmlT m ()
--navbar contentSpecificButtons = do



-- div_ [class_ "container-fluid"] $ do
