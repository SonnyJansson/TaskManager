{-# LANGUAGE OverloadedStrings #-}

module Main where

import Web.Spock
import Web.Spock.Config
import Web.Spock.Lucid (lucid)
import Lucid

type Server a = SpockM () () () a

app :: Server ()
app = get root $ lucid $ do
  h1_ "Hello!"
  p_ "How are you today?"

main :: IO ()
main = do
  cfg <- defaultSpockCfg () PCNoDatabase ()
  runSpock 8080 (spock cfg app)
