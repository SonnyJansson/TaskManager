{-# LANGUAGE OverloadedStrings, ExtendedDefaultRules, DuplicateRecordFields #-}

module NotesPage where

import Control.Monad
import Data.List
import Data.Semigroup
import qualified Data.Text as T
import Data.UUID

import Lucid
import Lucid.Base

import PageCommons
import Types

notesPage :: [Note] -> HtmlIO ()
notesPage = page content

content :: [Note] -> HtmlIO ()
content notes = do
  div_ [id_ "content", style_ "width: 100%"] $
    div_ [class_ "container-fluid", style_ "height: 100vh"] $ do
      div_ [class_ "row"] $
        nav_ [class_ "col-12 navbar navbar-expand-lg sticky-top navbar-light border-bottom"] $ do
          button_ [type_ "button", id_ "sidebarCollapse", class_ "btn btn-info", style_ "background-color: #2ecc71;"] $ do
            i_ [class_ "fas fa-bars"] ""
            --span_ "Toggle Sidebar"

          div_ [class_ "nav-item ml-auto"] $
            noteButtons

      div_ [class_ "row", style_ "height: 100%"] $ do
        div_ [class_ "col-lg-3 col-md-4 col-sm-5 col-10 pr-0 pl-0 notesMenuCol"] $ do
          notesMenu notes
        div_ [class_ "col-lg-9 col-md-8 col-sm-7 col-12 noteViewCol p-0", style_ "height: 100%"] $ do
          noteView
  modals


notesMenu :: Monad m => [Note] -> HtmlT m () -- POSSIBLY REMOVE THE RIGHT BORDER ON LIST ITEM WHEN THE NOTE IS OPENED TO MAKE IT LOOK LIKE IT IS "LEAKING" OVER INTO THE NOTE WINDOW AND TO MAKE IT STAND OUT A BIT MORE
notesMenu notes = do
  ul_ [class_ "list-group list-group-flush notesMenu", style_ "height: 100%"] $ do
    li_ [class_ "list-group-item pl-3 pr-2"] $
      input_ [class_ "form-control form-control-sm", type_ "text", placeholder_ "Search"]

    {-li_ [href_ "#", class_ "list-group-item list-group-item-action"] $ do
      h5_ [class_ "mb-1"] "Note 1"
      small_ [class_ "noteOutline"] "Notey notey notey"
      div_ [class_ "mt-1", style_ "overflow: hidden; white-space: nowrap; box-shadow: inset -4px 0px 5px 0px rgba(255,255,0,1);"] $ do
        span_ [class_ "badge badge-secondary mr-1"] "Life"
        span_ [class_ "badge badge-secondary mr-1"] "Life"
        span_ [class_ "badge badge-secondary"] "Life"

    li_ [class_ "list-group-item list-group-item-action"] $ do
      h5_ [class_ "mb-1"] "Note 2"
      small_ [class_ "noteOutline"] "Notey notey notey"

    li_ [class_ "list-group-item list-group-item-action"] $ do
      h5_ [class_ "mb-1"] "Note 3"
      small_ [class_ "noteOutline"] "Notey notey notey"

    li_ [class_ "list-group-item list-group-item-action"] $ do
      h5_ [class_ "mb-1"] "Note 4"
      small_ [class_ "noteOutline"] "Notey notey notey" -}

    mapM_ noteToHtml notes


noteToHtml :: Monad m => Note -> HtmlT m ()
noteToHtml note = do
  li_ [href_ "#", class_ "list-group-item list-group-item-action", onclick_ ("openDocument('" <> toText (noteUUID note) <> "','" <> noteName note <> "')")] $ do
    h5_ [class_ "mb-1"] (toHtml $ noteName note)
    small_ [class_ "noteOutline"] (toHtml $ noteOutline note)
    div_ [class_ "mt-1", style_ "overflow: hidden; white-space: nowrap;"{- box-shadow: inset -4px 0px 5px 0px rgba(255,255,0,1);"-}] $ do
      span_ [class_ "badge badge-secondary mr-1"] "Life"
      span_ [class_ "badge badge-secondary mr-1"] "Life"
      span_ [class_ "badge badge-secondary"] "Life"

noteView :: Monad m => HtmlT m ()
noteView = do
    nav_ [class_ "navbar navbar-light bg-light", id_ "noteNav"] $ do
      i_ [class_ "fas fa-arrow-left float-left navbarButtonGreen", onclick_ "openNotesMenu()"] ""
      span_ [class_ "mx-auto", id_ "noteNavName"] "Test Note"
    div_ [class_ "px-3 pt-1", id_ "noteView", style_ "height: 100%"] ""

noteButtons :: Monad m => HtmlT m ()
noteButtons = do
  i_ [class_ "fas fa-pen p-2 mr-2 navbarButtonGreen"] ""
  i_ [class_ "fas fa-cloud-download-alt p-2 mr-2 nav navbarButtonGreen"] ""
  i_ [class_ "fas fa-upload p-2 mr-2 navbarButtonGreen"] ""
  i_ [class_ "far fa-file p-2 navbarButtonGreen", id_ "newFile", makeAttribute "data-toggle" "modal", makeAttribute "data-target" "#newNoteModal"] ""


-- Differently coloured buttons for different pags, such as blue for projects and green for notes just to give them differet feels


modals :: Monad m => HtmlT m ()
modals = do
  div_ [class_ "modal fade", id_ "newNoteModal", tabindex_ "-1", role_ "dialog", makeAttribute "aria-labelledby" "newNoteLabel", makeAttribute "aria-hidden" "true"] $
    div_ [class_ "modal-dialog", role_ "document"] $
      div_ [class_ "modal-content"] $ do
        div_ [class_ "modal-header"] $ do
          h5_ [class_ "modal-title", id_ "newNoteLabel"] "New Note"
          button_ [type_ "button", class_ "close", makeAttribute "data-dismiss" "modal", makeAttribute "aria-label" "Close"] $
            span_ [makeAttribute "aria-hidden" "true"] ""
        div_ [class_ "modal-body"] $
          form_ $ do
            div_ [class_ "form-group"] $ do
              label_ [for_ "inputNoteName"] "Name"
              input_ [type_ "text", class_ "form-control", id_ "inputNoteName", placeholder_ "Enter note name"]

            div_ [class_ "form-group"] $ do
              label_ [for_ "inputNoteFormat"] "Format"
              select_ [class_ "form-control", id_ "inputNoteFormat"] $ do
                option_ "Markdown"
                option_ "Org"

            div_ [class_ "form-group"] $ do
              label_ [for_ "inputNoteTags"] "Tags"
              input_ [type_ "text", class_ "form-control", id_ "inputNoteTags", placeholder_ "Add tags"]

            -- Maybe have a grid of available tags and as they are searched for, they are added

            div_ [class_ "modal-footer"] $
              button_ [type_ "submit", class_ "btn btn-primary", id_ "inputNoteCreate"] "Create note"

