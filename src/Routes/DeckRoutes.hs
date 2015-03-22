{-# LANGUAGE OverloadedStrings #-}
module Routes.DeckRoutes where

import Database.PostgreSQL.Simple

import Network.HTTP.Types.Status

import Web.Scotty
import qualified Web.Scotty as S


import DB.Deck.Model
import DB.Deck.Queries
import DB.CardSimple.Model
import DB.CardSimple.Queries    

import Routes.Utils    
    
deckRoutes :: Connection -> ScottyM ()
deckRoutes conn = do
  get "/flashbuild/api/deck/:deckId/cards" $ do
    deckId <- param "deckId"
    cs <- deckChildCardSimple conn deckId
    S.json cs

  get "/flashbuild/api/deck/:deckId" $ do
    deckId <- param "deckId"
    d <- singleDeck conn deckId
    case d of
      Just deck -> S.json $ (deck :: Deck)
      Nothing -> do S.status badRequest400
                    S.json $ buildErrorResp "Could not find deck!"

  put "/flashbuild/api/deck/:deckId" $ do
    u <- jsonData
    d <- updateDeck conn (u :: Deck)
    case d of
      Just deck -> S.json $ (deck :: Deck)
      Nothing -> do S.status badRequest400
                    S.json $ buildErrorResp "Could not update deck!"

  delete "/flashbuild/api/deck/:deckId" $ do
    deckId <- param "deckId"
    result <- deleteDeckAndCards conn deckId
    if result
    then S.status noContent204
    else do S.status badRequest400
            S.json $ buildErrorResp "Could not delete deck!"
      

  get "/flashbuild/api/deck" $ do
    ds <- allDecks conn
    S.json ds

  post "/flashbuild/api/deck" $ do
    newDeck <- jsonData
    d <- createDeck conn (newDeck :: Deck)
    S.json $ d
