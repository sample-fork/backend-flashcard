{-# LANGUAGE OverloadedStrings #-}
module DB.CardUser.Queries where

import Prelude hiding (id)    
import Control.Monad.IO.Class (liftIO)
import Data.Monoid ((<>))
import Data.Functor ((<$>))    
import Data.Text
import Data.Maybe  (listToMaybe)  
import Database.PostgreSQL.Simple

import Web.Scotty

import DB.CardUser.Model


getUserById :: Connection -> Int -> ActionM (Maybe CardUser)
getUserById conn userId = 
    liftIO $ listToMaybe <$> query conn singleUserQuery (Only userId)
  where
    singleUserQuery = "SELECT * FROM carduser WHERE id = ?"

getUserByCredentials :: Connection -> Text -> Text -> ActionM (Maybe CardUser)
getUserByCredentials conn uname passwd =
    liftIO $ listToMaybe <$> query conn userCredQuery (uname, passwd)
  where
    userCredQuery = "SELECT * FROM carduser WHERE username = ? " <>
                    "AND password = crypt(?, password)"
