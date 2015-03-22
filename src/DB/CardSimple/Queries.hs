{-# LANGUAGE OverloadedStrings, RecordWildCards #-}
module DB.CardSimple.Queries where


import Prelude hiding (id)    
import Control.Monad.IO.Class (liftIO)
import Data.Functor ((<$>))    
import Data.Maybe  (listToMaybe)  
import Data.Text.Lazy (Text)   
import Database.PostgreSQL.Simple

import Web.Scotty
    
import DB.CardSimple.Model



singleCard :: Connection -> Int -> ActionM (Maybe CardSimple)
singleCard conn cardId = 
    liftIO $ listToMaybe <$> query conn singleQuery (Only cardId)
  where
    singleQuery = "SELECT * FROM card_simple WHERE id = ? AND deleted = false"


createCard :: Connection -> CardSimple -> ActionM (Maybe CardSimple)
createCard conn (CardSimple {..}) = 
    liftIO $ listToMaybe <$> query conn createQuery vals
  where
    createQuery = "INSERT INTO card_simple (deck_id, front, back, info, created_by) VALUES (?, ?, ?, ?, ?) RETURNING *"
    vals = (deck_id, front, back, info, created_by)

updateCard :: Connection -> CardSimple -> ActionM (Maybe CardSimple)
updateCard conn c@(CardSimple {..}) = do
    liftIO $ listToMaybe <$> query conn updateQuery vals
  where
    updateQuery = "UPDATE card_simple SET deck_id = ?, front = ?, back = ?, info = ? WHERE id = ? RETURNING *"
    vals = (deck_id, front, back, info, id)

deleteCard :: Connection -> Int -> ActionM Bool           
deleteCard conn cardId = do
  let deleteQuery = "UPDATE card_simple SET deleted = true WHERE id = ?"
  numRows <- liftIO $ execute conn deleteQuery (Only cardId)
  return $ if numRows == 1 then True else False
