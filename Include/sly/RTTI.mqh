//+------------------------------------------------------------------+
//|                                                         RTTI.mqh |
//|                                     Copyright 2025, sylsoftwares |
//|                                      https://www.slysoftware.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, sylsoftwares"
#property link      "https://www.slysoftware.com"

template<typename T>
ENUM_DATATYPE rtti(T v = (T)NULL)
 {
  static string types[] =
   {
    "null",
    "bool",
    "char",
    "uchar",
    "short",
    "ushort",
    "color",
    "int",
    "uint",
    "datetime",
    "long",
    "ulong",
    "float",
    "double",
    "string",
   };

  const string t = typename(T);
  for(int i = 0; i < ArraySize(types); ++i)
   {
    if(types[i] == t)
      return (ENUM_DATATYPE)i;
   }
  return (ENUM_DATATYPE)0;
 }
//+------------------------------------------------------------------+
