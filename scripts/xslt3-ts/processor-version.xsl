<?xml version="1.0"?>
<?xml-stylesheet href="processor-version.xsl" type="text/xsl"?>
<!-- ============================================================= -->
<!-- MODULE:    XSL Processor Version Detection Stylesheet         -->
<!-- version: 2009-02-19 [trg/wap]                                 -->
<!--          with Opera bug workaround from cmsmcq                -->
<!-- ============================================================= -->

<html xsl:version="1.0"
      xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
      xmlns="http://www.w3.org/1999/xhtml">
  <head>
    <title>XSLT Processor Version</title>
  </head>
  <body>

    <p>
      <xsl:text>XSL version: </xsl:text>
      <xsl:choose>
        <xsl:when test="system-property('xsl:vendor') = 'Opera'">1.0</xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="system-property('xsl:version')"/>
        </xsl:otherwise>
      </xsl:choose>
    </p>

    <p>
      <xsl:text>Vendor: </xsl:text>
      <xsl:value-of select="system-property('xsl:vendor')"/>
    </p>

    <p>
      <xsl:text>Vendor URL: </xsl:text>
      <xsl:value-of select="system-property('xsl:vendor-url')"/>
    </p>

    <xsl:variable name="product" select="system-property('xsl:product-name')"/>
    <xsl:if test="normalize-space($product)">
    <p>
        <xsl:text>Product name: </xsl:text>

        <xsl:value-of select="$product"/>
    </p>
    </xsl:if>
    
    <xsl:variable name="product-version" select="system-property('xsl:product-version')"/>
    <xsl:if test="normalize-space($product-version)">
    <p>
        <xsl:text>Product version: </xsl:text>
        <xsl:value-of select="$product-version"/>

    </p>
    </xsl:if>
    
    <xsl:variable name="schema-aware" select="system-property('xsl:is-schema-aware')"/>
    <xsl:if test="normalize-space($schema-aware)">
    <p>
        <xsl:text>Is schema-aware: </xsl:text>
        <xsl:value-of select="$schema-aware"/>
    </p>

    </xsl:if>
    
    <xsl:variable name="serialization" select="system-property('xsl:supports-serialization')"/>
    <xsl:if test="normalize-space($serialization)">
    <p>
        <xsl:text>Supports serialization: </xsl:text>
        <xsl:value-of select="$serialization"/>
    </p>
    </xsl:if>

    <xsl:variable name="backwards-compatible" select="system-property('xsl:supports-backwards-compatibility')"/>
    <xsl:if test="normalize-space($backwards-compatible)">
    <p>
        <xsl:text>Supports backwards compatibility: </xsl:text>
        <xsl:value-of select="$backwards-compatible"/>
    </p>
    </xsl:if>

  </body>

</html>
