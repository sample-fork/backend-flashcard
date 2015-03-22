{-# LANGUAGE OverloadedStrings, DeriveGeneric #-}
module Routes.SessionRoutes where

import Prelude hiding (id)
    
import GHC.Generics
import Database.PostgreSQL.Simple
import Data.Aeson
import Data.Text    
import Network.HTTP.Types.Status

import Web.Scotty
import qualified Web.Scotty as S

import DB.CardUser.Model hiding (username, password, id)
import DB.CardUserSession.Model
import DB.CardUserSession.Queries    

import Routes.Utils    


data LoginInfo = LoginInfo
    { username :: Text
    , password :: Text
    } deriving (Generic, Show)
instance FromJSON LoginInfo
instance ToJSON LoginInfo

sessionRoutes :: Connection -> ScottyM ()
sessionRoutes conn = do
  post "/flashbuild/api/user/login" $ do
    u <- jsonData 
    login <- loginUser conn (username u) (password (u :: LoginInfo))
    case login of
      Just session -> S.json session
      Nothing -> do S.status badRequest400
                    S.json $ buildErrorResp "Could not loging" 

  post "/flashbuild/api/user/logout" $ do
    s <- jsonData 
    result <- deleteSession conn $ id (s :: CardUserSession)
    if result
    then S.text "{ logout: true }"
    else do S.status badRequest400
            S.json $ buildErrorResp "Problems logging out! YOU'RE STUCK!"
                       
