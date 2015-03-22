{-# LANGUAGE OverloadedStrings, RecordWildCards #-}

module DB.Deck.Queries where

import Prelude hiding (id)    
import Control.Monad.IO.Class (liftIO)
import Data.Functor ((<$>))    
import Data.Maybe  (listToMaybe)  
import Data.Text.Lazy (Text)   
import Database.PostgreSQL.Simple

import Debug.Trace
    
import Web.Scotty
    
import DB.Deck.Model
import DB.CardSimple.Model    

    
allDecks :: Connection -> ActionM [Deck]
allDecks conn = liftIO $ query_ conn "SELECT * FROM deck WHERE deleted = false"

singleDeck :: Connection -> Int -> ActionM (Maybe Deck)
singleDeck conn deckId = liftIO $ listToMaybe <$> query conn singleQuery (Only deckId)
    where 
      singleQuery = "SELECT * FROM deck WHERE id = ? and deleted = false"
              
allDecksPaged :: Connection -> Int -> Int -> ActionM [Deck]
allDecksPaged conn limit offset = liftIO $ query conn pagedQuery (limit, offset)
    where
      pagedQuery = "SELECT * FROM deck WHERE deleted = false LIMIT ? OFFSET ?"

deckChildCardSimple :: Connection -> Int -> ActionM [CardSimple]
deckChildCardSimple conn deckId = liftIO $ query conn cardQuery (Only deckId)
    where
      cardQuery = "SELECT * FROM card_simple WHERE deck_id = ? AND deleted = false"


createDeck :: Connection -> Deck -> ActionM (Maybe Deck)
createDeck conn (Deck {..}) = liftIO $ listToMaybe <$> query conn createQuery (name, description, created_by)
    where
      createQuery = "INSERT INTO deck (name, description, created_by) VALUES (?, ?, ?) RETURNING *"

updateDeck :: Connection -> Deck -> ActionM (Maybe Deck)
updateDeck conn (Deck {..}) = do newD <- liftIO $ listToMaybe <$> query conn updateQuery (name, description, id)
                                 trace (tStr newD) $ return newD
    where
      updateQuery = "UPDATE deck  SET name = ?, description = ? WHERE id = ? RETURNING *"
      tStr d = "Updated deck to: " ++ show d
                    
deleteDeckAndCards :: Connection -> Int -> ActionM Bool
deleteDeckAndCards conn deckId = do
  let deleteDeckQuery = "UPDATE deck SET deleted = true WHERE id = ?"
      deleteCardQuery = "UPDATE card_simple SET deleted = true WHERE deck_id = ?"
  _       <- liftIO $ execute conn deleteCardQuery (Only deckId)
  numRows <- liftIO $ execute conn deleteDeckQuery (Only deckId)
  return $ if numRows == 1 then True else False 


