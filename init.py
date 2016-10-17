# !/usr/bin/evn python
# -*- coding: utf8 -*-

from ppmessage.core.constant import SQL
from ppmessage.db.dbinstance import BaseModel
from ppmessage.db.dbinstance import getDatabaseEngine


_engine = getDatabaseEngine()
BaseModel.metadata.create_all(_engine)
