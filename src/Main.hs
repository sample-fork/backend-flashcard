{-# LANGUAGE OverloadedStrings #-}

module Main where

import Control.Monad (when)
import Control.Monad.IO.Class
import Control.Applicative
import Database.PostgreSQL.Simple

import Data.Aeson

import Network.HTTP.Types.Status
import Network.Wai.Handler.Warp (run)
import Control.Monad.Trans.Resource (ResourceT)

import Web.Scotty
import qualified Web.Scotty as S

import Routes.DeckRoutes
import Routes.CardRoutes
import Routes.CardUserRoutes    
import Routes.SessionRoutes

import DB


main :: IO ()
main = do
  conn <- connect cardDBInfo
  scotty 3030 $ do     
    deckRoutes conn
    cardRoutes conn
    userRoutes conn
    sessionRoutes conn
  close conn
      
