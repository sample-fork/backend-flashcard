{-# LANGUAGE OverloadedStrings, DeriveGeneric #-}
module Routes.CardUserRoutes where

import Prelude hiding (id)
    
import Database.PostgreSQL.Simple
import Data.Aeson
import Network.HTTP.Types.Status

import Web.Scotty
import qualified Web.Scotty as S

import DB.CardUser.Model
import DB.CardUser.Queries    

import Routes.Utils    

userRoutes :: Connection -> ScottyM ()
userRoutes conn = do
  get "/flashbuild/api/user/:userId" $ do
    userId <- param "userId"
    u <- getUserById conn userId
    case u of
      Just user -> S.json $ (user :: CardUser)
      Nothing   -> do S.status notFound404
                      S.json $ buildErrorResp "Could not find user!" 
