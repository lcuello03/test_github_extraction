CREATE OR REPLACE PROCEDURE BIFROSTTEST.PUBLIC.RISESALARY(P_DEPT_ID VARIANT, P_RISE VARIANT)
RETURNS VARCHAR(16777216)
LANGUAGE JAVASCRIPT
EXECUTE AS CALLER
AS 
$$
    // REGION SnowConvert Helpers Code
   var formatDate = (arg) => (new Date(arg - (arg.getTimezoneOffset() * 60000))).toISOString().slice(0,-1);
   var fixBind = function (arg) {
      arg = arg instanceof Date ? formatDate(arg) : IS_NULL(arg) ? null : arg;
      return arg;
   };
   var SQL = {
      FOUND : false,
      NOTFOUND : false,
      ROWCOUNT : 0,
      ISOPEN : false
   };
   var _RS, _ROWS, SQLERRM = "normal, successful completion", SQLCODE = 0;
   var getObj = (_rs) => Object.assign(new Object(),_rs);
   var getRow = (_rs) => (values = Object.values(_rs)) && (values = values.splice(-1 * _rs.getColumnCount())) && values;
   var fetch = (_RS,_ROWS,fmode) => _RS.getRowCount() && _ROWS.next() && (fmode ? getObj : getRow)(_ROWS) || (fmode ? new Object() : []);
   var EXEC = function (stmt,binds,opts) {
      try {
         binds = !(arguments[1] instanceof Array) && ((opts = arguments[1]) && []) || (binds || []);
         opts = opts || new Object();
         binds = binds ? binds.map(fixBind) : binds;
         _RS = snowflake.createStatement({
               sqlText : stmt,
               binds : binds
            });
         _ROWS = _RS.execute();
         if (opts.sql !== 0) {
            var isSelect = stmt.toUpperCase().trimStart().startsWith("SELECT");
            var affectedRows = isSelect ? _RS.getRowCount() : _RS.getNumRowsAffected();
            SQL.FOUND = affectedRows != 0;
            SQL.NOTFOUND = affectedRows == 0;
            SQL.ROWCOUNT = affectedRows;
         }
         if (opts.row === 2) {
            return _ROWS;
         }
         var INTO = function (opts) {
            if (opts.vars == 1 && _RS.getColumnCount() == 1 && _ROWS.next()) {
               return _ROWS.getColumnValue(1);
            }
            if (opts.rec instanceof Object && _ROWS.next()) {
               var recordKeys = Object.keys(opts.rec);
               Object.assign(opts.rec,Object.fromEntries(new Map(getRow(_ROWS).map((element,Index) => [recordKeys[Index],element]))))
               return opts.rec;
            }
            return fetch(_RS,_ROWS,opts.row);
         };
         var BULK_INTO_COLLECTION = function (into) {
            for(let i = 0;i < _RS.getRowCount();i++) {
               FETCH_INTO_COLLECTIONS(into,fetch(_RS,_ROWS,opts.row));
            }
            return into;
         };
         if (_ROWS.getRowCount() > 0) {
            return _ROWS.getRowCount() == 1 ? INTO(opts) : BULK_INTO_COLLECTION(opts);
         }
      } catch(error) {
         RAISE(error.code,error.name,error.message)
      }
   };
   var RAISE = function (code,name,message) {
      message === undefined && ([name,message] = [message,name])
      var error = new Error(message);
      error.name = name
      SQLERRM = `${(SQLCODE = (error.code = code))}: ${message}`
      throw error;
   };
   var FETCH_INTO_COLLECTIONS = function (collections,fetchValues) {
      for(let i = 0;i < collections.length;i++) {
         collections[i].push(fetchValues[i]);
      }
   };
   var IS_NULL = (arg) => !(arg || arg === 0);
    // END REGION

   EXEC(`UPDATE Dept SET Dept_Sal = /*** MSC-WARNING - MSCEWI3036 - TYPES RESOLUTION ISSUES, ARITHMETIC OPERATION '+' MAY NOT BEHAVE CORRECTLY BETWEEN ExactNumeric AND unknown **/*
 Dept_Sal + ? where Dept.Dept_ID = ?`,[P_RISE * /** MSC-WARNING - MSCEWI1053 - OBJECT p_Rise MAY NOT WORK PROPERLY, ITS DATATYPE WAS NOT RECOGNIZED **/ *,P_DEPT_ID * /** MSC-WARNING - MSCEWI1053 - OBJECT p_Dept_ID MAY NOT WORK PROPERLY, ITS DATATYPE WAS NOT RECOGNIZED **/ *]);
$$;
