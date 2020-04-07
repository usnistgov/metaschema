<?xml version="1.0" encoding="UTF-8"?>
<!-- This file was generated on Tue Apr 7, 2020 11:36 (UTC-04) by REx v5.49 which is Copyright (c) 1979-2019 by Gunther Rademacher <grd@gmx.net> -->
<!-- REx command line: xpath-halfpath.ebnf -backtrack -xslt -tree -name xpath-halfpath -->

<xsl:stylesheet version="2.0"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:p="xpath-halfpath">
  <!--~
   ! The index of the lexer state for accessing the combined
   ! (i.e. level > 1) lookahead code.
  -->
  <xsl:variable name="p:lk" as="xs:integer" select="1"/>

  <!--~
   ! The index of the lexer state for accessing the position in the
   ! input string of the begin of the token that has been consumed.
  -->
  <xsl:variable name="p:b0" as="xs:integer" select="2"/>

  <!--~
   ! The index of the lexer state for accessing the position in the
   ! input string of the end of the token that has been consumed.
  -->
  <xsl:variable name="p:e0" as="xs:integer" select="3"/>

  <!--~
   ! The index of the lexer state for accessing the code of the
   ! level-1-lookahead token.
  -->
  <xsl:variable name="p:l1" as="xs:integer" select="4"/>

  <!--~
   ! The index of the lexer state for accessing the position in the
   ! input string of the begin of the level-1-lookahead token.
  -->
  <xsl:variable name="p:b1" as="xs:integer" select="5"/>

  <!--~
   ! The index of the lexer state for accessing the position in the
   ! input string of the end of the level-1-lookahead token.
  -->
  <xsl:variable name="p:e1" as="xs:integer" select="6"/>

  <!--~
   ! The index of the lexer state for accessing the token code that
   ! was expected when an error was found.
  -->
  <xsl:variable name="p:error" as="xs:integer" select="7"/>

  <!--~
   ! The index of the lexer state that points to the first entry
   ! used for collecting action results.
  -->
  <xsl:variable name="p:result" as="xs:integer" select="8"/>

  <!--~
   ! The codepoint to charclass mapping for 7 bit codepoints.
  -->
  <xsl:variable name="p:MAP0" as="xs:integer+" select="
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 2, 0, 2, 2, 2, 2,
    2, 2, 2, 2, 2, 2, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 1, 0, 1, 1, 1, 1, 1, 1, 1,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0
  "/>

  <!--~
   ! The codepoint to charclass mapping for codepoints below the surrogate block.
  -->
  <xsl:variable name="p:MAP1" as="xs:integer+" select="
    595, 108, 172, 298, 362, 236, 426, 536, 472, 330, 330, 330, 330, 330, 330, 659, 761, 330, 330, 330, 330, 330, 330, 330, 723, 330, 330, 330, 330, 330, 330,
    330, 330, 330, 330, 330, 330, 330, 330, 330, 330, 330, 330, 330, 330, 330, 330, 330, 330, 330, 330, 330, 330, 330, 330, 330, 330, 330, 330, 330, 330, 330,
    330, 330, 330, 330, 330, 330, 330, 330, 330, 330, 330, 330, 330, 330, 330, 330, 330, 330, 330, 330, 330, 330, 330, 330, 825, 825, 825, 825, 825, 825, 825,
    825, 825, 825, 825, 825, 825, 825, 825, 825, 825, 825, 825, 825, 825, 837, 944, 944, 944, 1071, 1071, 1071, 1071, 1071, 1071, 1071, 944, 944, 944, 944, 944,
    944, 944, 944, 944, 944, 944, 1070, 1071, 1260, 1069, 1071, 1093, 1071, 1071, 1071, 1071, 1071, 1087, 1087, 1087, 1087, 1087, 1087, 1087, 1087, 1089, 1071,
    1071, 1071, 1093, 1071, 1071, 1071, 1228, 1041, 944, 944, 1061, 944, 944, 944, 944, 1064, 1064, 1247, 1062, 944, 1067, 1071, 1063, 901, 944, 944, 944, 944,
    944, 944, 944, 944, 1063, 901, 944, 944, 944, 944, 910, 1071, 944, 944, 944, 944, 944, 944, 923, 932, 944, 944, 944, 924, 1065, 1069, 1071, 1071, 1071,
    1071, 1071, 1071, 1063, 944, 944, 944, 1064, 1271, 1063, 944, 944, 944, 1064, 1071, 1086, 1087, 976, 1087, 1087, 958, 1223, 1071, 944, 944, 944, 1068, 1068,
    1071, 1286, 1051, 1187, 944, 944, 1062, 1237, 1013, 994, 991, 1071, 1039, 1274, 1087, 1049, 1071, 1300, 1040, 1061, 944, 944, 1062, 1059, 970, 1138, 915,
    1071, 1071, 1081, 1087, 1071, 1071, 1300, 923, 1187, 944, 944, 1062, 1184, 970, 1019, 991, 1274, 1028, 935, 1087, 1071, 1071, 1209, 1101, 1117, 1113, 1005,
    1101, 1125, 935, 1020, 1017, 1273, 1071, 1273, 1087, 1071, 1071, 1071, 1071, 1063, 944, 944, 1068, 943, 1150, 1092, 1071, 1087, 1093, 943, 944, 944, 944,
    944, 944, 944, 944, 944, 1188, 944, 1064, 952, 1087, 1153, 1017, 1087, 1093, 1071, 1071, 1071, 1071, 1071, 1071, 1071, 1071, 1071, 1071, 1071, 1071, 1071,
    1071, 1071, 1071, 1071, 1071, 1071, 1071, 1071, 1071, 1071, 1071, 1071, 1071, 1071, 1071, 1071, 1071, 1071, 1071, 1071, 1071, 1071, 1071, 1071, 1071, 1071,
    1071, 1071, 1071, 1071, 1071, 1071, 1071, 1071, 1071, 1071, 1071, 1071, 1071, 1071, 1071, 1071, 1071, 1071, 1071, 1071, 1071, 1071, 1071, 1071, 1071, 1300,
    944, 944, 944, 944, 944, 944, 970, 1087, 1089, 1018, 944, 988, 1087, 1071, 1071, 1300, 923, 1187, 944, 944, 1062, 1002, 1013, 979, 991, 1273, 1028, 988,
    1087, 1069, 1071, 1300, 901, 1062, 944, 944, 1062, 902, 935, 1139, 1017, 1275, 1071, 935, 1087, 1071, 1071, 1209, 901, 1062, 944, 944, 1062, 902, 935, 1139,
    1017, 1275, 1073, 935, 1087, 1071, 1071, 1209, 901, 1062, 944, 944, 1062, 944, 935, 980, 1017, 1273, 1071, 935, 1087, 1071, 1071, 1071, 1071, 1071, 1071,
    1071, 1071, 1071, 1071, 1071, 1071, 1071, 1071, 1071, 1071, 1071, 1071, 1071, 1071, 944, 944, 944, 944, 1065, 1071, 944, 944, 944, 944, 1064, 1071, 1059,
    1236, 1068, 1071, 1071, 1071, 1071, 1245, 1070, 1245, 1004, 1256, 1173, 1003, 1030, 1071, 1071, 1071, 1071, 1073, 1071, 1163, 1072, 1115, 1068, 1071, 1071,
    1071, 1071, 1269, 1070, 1271, 1063, 944, 944, 944, 944, 1064, 1134, 1092, 1147, 1088, 1087, 1093, 1071, 1071, 1071, 1071, 1031, 1161, 1259, 1063, 1171,
    1181, 1134, 962, 1196, 1089, 1087, 1093, 1071, 1071, 1071, 1071, 1071, 1071, 1071, 1093, 1087, 1093, 1217, 1201, 944, 1063, 944, 944, 944, 1069, 1086, 1087,
    1139, 1091, 1138, 1086, 1087, 1089, 1086, 1226, 1071, 1071, 1071, 1071, 1071, 1071, 1071, 1071, 1275, 1087, 1093, 1063, 944, 944, 1051, 1063, 944, 944,
    1068, 1071, 1071, 1071, 1071, 1071, 1071, 1273, 1071, 944, 944, 1064, 944, 944, 944, 1064, 944, 944, 944, 944, 944, 944, 944, 1186, 1064, 1063, 1062, 944,
    944, 944, 944, 944, 1064, 944, 944, 944, 944, 944, 944, 944, 944, 1067, 1258, 944, 944, 944, 944, 1004, 1261, 944, 944, 944, 944, 944, 944, 944, 944, 944,
    944, 944, 944, 944, 944, 944, 944, 944, 944, 944, 1067, 944, 944, 944, 944, 944, 944, 944, 944, 944, 944, 944, 1069, 944, 944, 1065, 1065, 944, 944, 944,
    944, 1065, 1065, 944, 1248, 944, 944, 944, 1065, 944, 944, 944, 944, 944, 944, 901, 1126, 1289, 1066, 924, 1067, 944, 1066, 1289, 1066, 1283, 1071, 1071,
    1071, 1071, 1085, 978, 1071, 1063, 944, 944, 944, 944, 944, 944, 944, 944, 944, 1066, 1206, 1063, 944, 944, 944, 944, 944, 944, 944, 944, 944, 944, 1297,
    1258, 944, 944, 944, 944, 1066, 1071, 1071, 1071, 1071, 1071, 1071, 1071, 1071, 1071, 1071, 1071, 1071, 1071, 1071, 1071, 1071, 1071, 1071, 1071, 1071,
    1071, 1071, 1071, 1071, 1071, 1071, 1087, 1090, 1226, 1071, 1071, 1071, 1071, 1071, 1071, 1071, 1073, 1105, 1071, 1071, 1071, 1071, 1071, 1071, 1071, 1071,
    1071, 1071, 1068, 1071, 1071, 1071, 1071, 1071, 1071, 1071, 1071, 1071, 1071, 1071, 1071, 1071, 1071, 1071, 944, 944, 944, 944, 944, 944, 944, 944, 944,
    944, 944, 944, 944, 944, 944, 944, 944, 944, 944, 944, 944, 944, 944, 944, 944, 944, 944, 944, 944, 944, 944, 944, 944, 944, 944, 944, 944, 944, 944, 944,
    944, 944, 944, 944, 944, 944, 944, 944, 944, 944, 944, 944, 944, 944, 944, 944, 944, 944, 944, 944, 944, 944, 944, 944, 1067, 1071, 1071, 1071, 1071, 1071,
    1071, 1071, 1071, 1071, 1071, 1071, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 0, 2, 2, 2, 2, 0, 2, 2, 2, 0, 0, 1, 1, 1, 1, 1, 0, 0, 1, 1, 1, 0, 0, 1, 1, 0, 0, 0, 0,
    2, 2, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 2, 2, 0, 2, 2, 2, 0, 2, 2, 1, 0, 0, 1, 1, 0, 0, 2, 1, 2, 2, 0, 2, 2, 2, 2, 2, 0, 0, 2, 2, 1, 1, 2, 2, 0,
    0, 2, 2, 2, 0, 0, 0, 0, 2, 1, 0, 1, 0, 0, 0, 1, 1, 0, 0, 0, 1, 1, 0, 0, 2, 0, 2, 2, 2, 2, 0, 0, 0, 2, 2, 0, 0, 0, 0, 1, 1, 0, 1, 0, 0, 1, 0, 1, 1, 1, 1, 0,
    1, 0, 1, 1, 2, 2, 1, 1, 1, 0, 0, 0, 0, 1, 1, 0, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 2, 2, 2, 2, 2, 2, 2, 2, 0, 0,
    0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 1, 1, 0, 0, 1, 0, 0, 1, 1, 0, 1, 0, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 1, 1, 0, 1, 0, 1, 2, 1, 1, 2, 2, 2, 2, 2, 2, 0, 2, 2, 1, 1,
    1, 1, 1, 1, 2, 2, 2, 2, 2, 1, 1, 2, 1, 0, 1, 0, 0, 1, 0, 0, 1, 1, 0, 1, 1, 1, 0, 1, 0, 1, 0, 1, 0, 0, 1, 1, 0, 1, 1, 0, 0, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1,
    0, 2, 0, 0, 0, 0, 2, 2, 0, 0, 2, 2, 0, 1, 1, 1, 0, 0, 0, 0, 0, 2, 0, 2, 2, 0, 2, 0, 0, 0, 0, 0, 0, 1, 2, 0, 1, 0, 1, 1, 0, 1, 1, 0, 0, 0, 0, 0, 1, 0, 1, 0,
    1, 0, 1, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 2, 2, 0, 0, 0, 0, 0, 0, 2, 0, 0, 1, 1, 1, 0, 1, 1, 1, 1, 1, 0, 2, 2, 2, 0,
    1, 1, 1
  "/>

  <!--~
   ! The token-set-id to DFA-initial-state mapping.
  -->
  <xsl:variable name="p:INITIAL" as="xs:integer+" select="
    1, 10
  "/>

  <!--~
   ! The DFA transition table.
  -->
  <xsl:variable name="p:TRANSITION" as="xs:integer+" select="
    0, 0, 12, 16, 0, 16
  "/>

  <!--~
   ! The DFA-state to expected-token-set mapping.
  -->
  <xsl:variable name="p:EXPECTED" as="xs:integer+" select="
    4, 8
  "/>

  <!--~
   ! The token-string table.
  -->
  <xsl:variable name="p:TOKEN" as="xs:string+" select="
    '(0)',
    'END',
    'NCNameStartChar',
    'NCNameChar'
  "/>

  <!--~
   ! Match next token in input string, starting at given index, using
   ! the DFA entry state for the set of tokens that are expected in
   ! the current context.
   !
   ! @param $input the input string.
   ! @param $begin the index where to start in input string.
   ! @param $token-set the expected token set id.
   ! @return a sequence of three: the token code of the result token,
   ! with input string begin and end positions. If there is no valid
   ! token, return the negative id of the DFA state that failed, along
   ! with begin and end positions of the longest viable prefix.
  -->
  <xsl:function name="p:match" as="xs:integer+">
    <xsl:param name="input" as="xs:string"/>
    <xsl:param name="begin" as="xs:integer"/>
    <xsl:param name="token-set" as="xs:integer"/>

    <xsl:variable name="result" select="$p:INITIAL[1 + $token-set]"/>
    <xsl:sequence select="p:transition($input, $begin, $begin, $begin, $result, $result mod 4, 0)"/>
  </xsl:function>

  <!--~
   ! The DFA state transition function. If we are in a valid DFA state, save
   ! it's result annotation, consume one input codepoint, calculate the next
   ! state, and use tail recursion to do the same again. Otherwise, return
   ! any valid result or a negative DFA state id in case of an error.
   !
   ! @param $input the input string.
   ! @param $begin the begin index of the current token in the input string.
   ! @param $current the index of the current position in the input string.
   ! @param $end the end index of the result in the input string.
   ! @param $result the result code.
   ! @param $current-state the current DFA state.
   ! @param $previous-state the  previous DFA state.
   ! @return a sequence of three: the token code of the result token,
   ! with input string begin and end positions. If there is no valid
   ! token, return the negative id of the DFA state that failed, along
   ! with begin and end positions of the longest viable prefix.
  -->
  <xsl:function name="p:transition">
    <xsl:param name="input" as="xs:string"/>
    <xsl:param name="begin" as="xs:integer"/>
    <xsl:param name="current" as="xs:integer"/>
    <xsl:param name="end" as="xs:integer"/>
    <xsl:param name="result" as="xs:integer"/>
    <xsl:param name="current-state" as="xs:integer"/>
    <xsl:param name="previous-state" as="xs:integer"/>

    <xsl:choose>
      <xsl:when test="$current-state eq 0">
        <xsl:variable name="result" select="$result idiv 4"/>
        <xsl:variable name="end" select="if ($end gt string-length($input)) then string-length($input) + 1 else $end"/>
        <xsl:sequence select="
          if ($result ne 0) then
          (
            $result - 1,
            $begin,
            $end
          )
          else
          (
            - $previous-state,
            $begin,
            $current - 1
          )
        "/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="c0" select="(string-to-codepoints(substring($input, $current, 1)), 0)[1]"/>
        <xsl:variable name="c1" as="xs:integer">
          <xsl:choose>
            <xsl:when test="$c0 &lt; 128">
              <xsl:sequence select="$p:MAP0[1 + $c0]"/>
            </xsl:when>
            <xsl:when test="$c0 &lt; 55296">
              <xsl:variable name="c1" select="$c0 idiv 8"/>
              <xsl:variable name="c2" select="$c1 idiv 64"/>
              <xsl:sequence select="$p:MAP1[1 + $c0 mod 8 + $p:MAP1[1 + $c1 mod 64 + $p:MAP1[1 + $c2]]]"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:sequence select="0"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="current" select="$current + 1"/>
        <xsl:variable name="i0" select="2 * $c1 + $current-state - 1"/>
        <xsl:variable name="next-state" select="$p:TRANSITION[$i0 + 1]"/>
        <xsl:sequence select="
          if ($next-state &gt; 3) then
            p:transition($input, $begin, $current, $current, $next-state, $next-state mod 4, $current-state)
          else
            p:transition($input, $begin, $current, $end, $result, $next-state, $current-state)
        "/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!--~
   ! Recursively translate one 32-bit chunk of an expected token bitset
   ! to the corresponding sequence of token strings.
   !
   ! @param $result the result of previous recursion levels.
   ! @param $chunk the 32-bit chunk of the expected token bitset.
   ! @param $base-token-code the token code of bit 0 in the current chunk.
   ! @return the set of token strings.
  -->
  <xsl:function name="p:token">
    <xsl:param name="result" as="xs:string*"/>
    <xsl:param name="chunk" as="xs:integer"/>
    <xsl:param name="base-token-code" as="xs:integer"/>

    <xsl:sequence select="
      if ($chunk = 0) then
        $result
      else
        p:token
        (
          ($result, if ($chunk mod 2 != 0) then $p:TOKEN[$base-token-code] else ()),
          if ($chunk &lt; 0) then $chunk idiv 2 + 2147483648 else $chunk idiv 2,
          $base-token-code + 1
        )
    "/>
  </xsl:function>

  <!--~
   ! Calculate expected token set for a given DFA state as a sequence
   ! of strings.
   !
   ! @param $state the DFA state.
   ! @return the set of token strings
  -->
  <xsl:function name="p:expected-token-set" as="xs:string*">
    <xsl:param name="state" as="xs:integer"/>

    <xsl:if test="$state > 0">
      <xsl:for-each select="0 to 0">
        <xsl:variable name="i0" select=". * 2 + $state - 1"/>
        <xsl:sequence select="p:token((), $p:EXPECTED[$i0 + 1], . * 32 + 1)"/>
      </xsl:for-each>
    </xsl:if>
  </xsl:function>

  <!--~
   ! Parse the 1st loop of production NCName (zero or more). Use
   ! tail recursion for iteratively updating the lexer state.
   !
   ! @param $input the input string.
   ! @param $state lexer state, error indicator, and result.
   ! @return the updated state.
  -->
  <xsl:function name="p:parse-NCName-1">
    <xsl:param name="input" as="xs:string"/>
    <xsl:param name="state" as="item()+"/>

    <xsl:choose>
      <xsl:when test="$state[$p:error]">
        <xsl:sequence select="$state"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="state" select="p:lookahead1(1, $input, $state)"/>       <!-- END | NCNameChar -->
        <xsl:choose>
          <xsl:when test="$state[$p:l1] != 3">                                      <!-- NCNameChar -->
            <xsl:sequence select="$state"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:variable name="state" select="p:consume(3, $input, $state)"/>      <!-- NCNameChar -->
            <xsl:sequence select="p:parse-NCName-1($input, $state)"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!--~
   ! Parse NCName.
   !
   ! @param $input the input string.
   ! @param $state lexer state, error indicator, and result.
   ! @return the updated state.
  -->
  <xsl:function name="p:parse-NCName" as="item()+">
    <xsl:param name="input" as="xs:string"/>
    <xsl:param name="state" as="item()+"/>

    <xsl:variable name="count" select="count($state)"/>
    <xsl:variable name="begin" select="$state[$p:e0]"/>
    <xsl:variable name="state" select="p:lookahead1(0, $input, $state)"/>           <!-- NCNameStartChar -->
    <xsl:variable name="state" select="p:consume(2, $input, $state)"/>              <!-- NCNameStartChar -->
    <xsl:variable name="state" select="p:parse-NCName-1($input, $state)"/>
    <xsl:variable name="end" select="$state[$p:e0]"/>
    <xsl:sequence select="p:reduce($state, 'NCName', $count, $begin, $end)"/>
  </xsl:function>

  <!--~
   ! Create a textual error message from a parsing error.
   !
   ! @param $input the input string.
   ! @param $error the parsing error descriptor.
   ! @return the error message.
  -->
  <xsl:function name="p:error-message" as="xs:string">
    <xsl:param name="input" as="xs:string"/>
    <xsl:param name="error" as="element(error)"/>

    <xsl:variable name="begin" select="xs:integer($error/@b)"/>
    <xsl:variable name="context" select="string-to-codepoints(substring($input, 1, $begin - 1))"/>
    <xsl:variable name="linefeeds" select="index-of($context, 10)"/>
    <xsl:variable name="line" select="count($linefeeds) + 1"/>
    <xsl:variable name="column" select="($begin - $linefeeds[last()], $begin)[1]"/>
    <xsl:variable name="expected" select="if ($error/@x or $error/@ambiguous-input) then () else p:expected-token-set($error/@s)"/>
    <xsl:sequence select="
      string-join
      (
        (
          if ($error/@o) then
            ('syntax error, found ', $p:TOKEN[$error/@o + 1])
          else
            'lexical analysis failed',
          '&#10;',
          'while expecting ',
          if ($error/@x) then
            $p:TOKEN[$error/@x + 1]
          else
          (
            '['[exists($expected[2])],
            string-join($expected, ', '),
            ']'[exists($expected[2])]
          ),
          '&#10;',
          if ($error/@o or $error/@e = $begin) then
            ()
          else
            ('after successfully scanning ', string($error/@e - $begin), ' characters beginning '),
          'at line ', string($line), ', column ', string($column), ':&#10;',
          '...', substring($input, $begin, 64), '...'
        ),
        ''
      )
    "/>
  </xsl:function>

  <!--~
   ! Consume one token, i.e. compare lookahead token 1 with expected
   ! token and in case of a match, shift lookahead tokens down such that
   ! l1 becomes the current token, and higher lookahead tokens move down.
   ! When lookahead token 1 does not match the expected token, raise an
   ! error by saving the expected token code in the error field of the
   ! lexer state.
   !
   ! @param $code the expected token.
   ! @param $input the input string.
   ! @param $state lexer state, error indicator, and result.
   ! @return the updated state.
  -->
  <xsl:function name="p:consume" as="item()+">
    <xsl:param name="code" as="xs:integer"/>
    <xsl:param name="input" as="xs:string"/>
    <xsl:param name="state" as="item()+"/>

    <xsl:choose>
      <xsl:when test="$state[$p:error]">
        <xsl:sequence select="$state"/>
      </xsl:when>
      <xsl:when test="$state[$p:l1] eq $code">
        <xsl:variable name="begin" select="$state[$p:e0]"/>
        <xsl:variable name="end" select="$state[$p:b1]"/>
        <xsl:variable name="whitespace">
          <xsl:if test="$begin ne $end">
            <xsl:value-of select="substring($input, $begin, $end - $begin)"/>
          </xsl:if>
        </xsl:variable>
        <xsl:variable name="token" select="$p:TOKEN[1 + $state[$p:l1]]"/>
        <xsl:variable name="name" select="if (starts-with($token, &quot;'&quot;)) then 'TOKEN' else $token"/>
        <xsl:variable name="begin" select="$state[$p:b1]"/>
        <xsl:variable name="end" select="$state[$p:e1]"/>
        <xsl:variable name="node">
          <xsl:element name="{$name}">
            <xsl:sequence select="substring($input, $begin, $end - $begin)"/>
          </xsl:element>
        </xsl:variable>
        <xsl:sequence select="
          subsequence($state, $p:l1, 3),
          0, 0, 0,
          subsequence($state, 7),
          $whitespace/node(),
          $node/node()
        "/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="error">
          <xsl:element name="error">
            <xsl:attribute name="b" select="$state[$p:b1]"/>
            <xsl:attribute name="e" select="$state[$p:e1]"/>
            <xsl:choose>
              <xsl:when test="$state[$p:l1] lt 0">
                <xsl:attribute name="s" select="- $state[$p:l1]"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:attribute name="o" select="$state[$p:l1]"/>
                <xsl:attribute name="x" select="$code"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:element>
        </xsl:variable>
        <xsl:sequence select="
          subsequence($state, 1, $p:error - 1),
          $error/node(),
          subsequence($state, $p:error + 1)
        "/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!--~
   ! Lookahead one token on level 1.
   !
   ! @param $set the code of the DFA entry state for the set of valid tokens.
   ! @param $input the input string.
   ! @param $state lexer state, error indicator, and result stack.
   ! @return the updated state.
  -->
  <xsl:function name="p:lookahead1" as="item()+">
    <xsl:param name="set" as="xs:integer"/>
    <xsl:param name="input" as="xs:string"/>
    <xsl:param name="state" as="item()+"/>

    <xsl:choose>
      <xsl:when test="$state[$p:l1] ne 0">
        <xsl:sequence select="$state"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="match" select="
          p:match($input, $state[$p:e0], $set)
        "/>
        <xsl:sequence select="
          $match[1],
          subsequence($state, $p:b0, 2),
          $match,
          subsequence($state, 7)
        "/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!--~
   ! Reduce the result stack, creating a nonterminal element. Pop
   ! $count elements off the stack, wrap them in a new element
   ! named $name, and push the new element.
   !
   ! @param $state lexer state, error indicator, and result.
   ! @param $name the name of the result node.
   ! @param $count the number of child nodes.
   ! @param $begin the input index where the nonterminal begins.
   ! @param $end the input index where the nonterminal ends.
   ! @return the updated state.
  -->
  <xsl:function name="p:reduce" as="item()+">
    <xsl:param name="state" as="item()+"/>
    <xsl:param name="name" as="xs:string"/>
    <xsl:param name="count" as="xs:integer"/>
    <xsl:param name="begin" as="xs:integer"/>
    <xsl:param name="end" as="xs:integer"/>

    <xsl:variable name="node">
      <xsl:element name="{$name}">
        <xsl:sequence select="subsequence($state, $count + 1)"/>
      </xsl:element>
    </xsl:variable>
    <xsl:sequence select="subsequence($state, 1, $count), $node/node()"/>
  </xsl:function>

  <!--~
   ! Parse start symbol NCName from given string.
   !
   ! @param $s the string to be parsed.
   ! @return the result as generated by parser actions.
  -->
  <xsl:function name="p:parse-NCName" as="item()*">
    <xsl:param name="s" as="xs:string"/>

    <xsl:variable name="state" select="0, 1, 1, 0, 0, 0, false()"/>
    <xsl:variable name="state" select="p:parse-NCName($s, $state)"/>
    <xsl:variable name="error" select="$state[$p:error]"/>
    <xsl:choose>
      <xsl:when test="$error">
        <xsl:variable name="ERROR">
          <xsl:element name="ERROR">
            <xsl:sequence select="$error/@*, p:error-message($s, $error)"/>
          </xsl:element>
        </xsl:variable>
        <xsl:sequence select="$ERROR/node()"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="subsequence($state, $p:result)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

</xsl:stylesheet>