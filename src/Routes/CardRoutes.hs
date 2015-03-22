{-# LANGUAGE OverloadedStrings #-}
module Routes.CardRoutes where


import Database.PostgreSQL.Simple

import Network.HTTP.Types.Status

import Web.Scotty
import qualified Web.Scotty as S

import DB.CardSimple.Model
import DB.CardSimple.Queries    

import Routes.Utils    


cardRoutes :: Connection -> ScottyM ()
cardRoutes conn = do
  get "/flashbuild/api/card/:cardId" $ do
    cardId <- param "cardId"
    c <- singleCard conn cardId
    case c of
      Just card -> S.json $ (card :: CardSimple)
      Nothing   -> do S.status badRequest400
                      S.json $ buildErrorResp "Could not find card!"

  put "/flashbuild/api/card/:cardId" $ do
    u <- jsonData
    c <- updateCard conn (u :: CardSimple)
    case c of
      Just card -> S.json $ (card :: CardSimple)
      Nothing -> do S.status badRequest400
                    S.json $ buildErrorResp "Could not update card!"

  delete "/flashbuild/api/card/:cardId" $ do
    cardId <- param "cardId"
    result <- deleteCard conn cardId
    if result
    then S.status noContent204
    else do S.status badRequest400
            S.json $ buildErrorResp "Could not delete card!"
  
  post "/flashbuild/api/card" $ do
    newCard <- jsonData
    c <- createCard conn (newCard :: CardSimple)
    S.json $ c
