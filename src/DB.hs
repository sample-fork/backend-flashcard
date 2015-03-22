module DB where

import Database.PostgreSQL.Simple

cardDBInfo :: ConnectInfo
cardDBInfo =
  defaultConnectInfo { connectUser = "flashbuild"
                     , connectPassword = "justtouchitalready"
                     , connectDatabase = "flashbuild"
                     }
