<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsd="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xsd"
    version="2.0">
    <xsl:output method="xml" indent="yes"/>
    <xsl:variable name="Msgs" select="document('../../../XSD/GoE_Schema/GoE_messages.xsd')"/>
    <xsl:variable name="Segments" select="document('../../../XSD/GoE_Schema/GoE_segments.xsd')"/>
    <xsl:variable name="Sets" select="document('../../../XSD/GoE_Schema/GoE_sets.xsd')"/>
    <xsl:variable name="Fields" select="document('../../../XSD/GoE_Schema/GoE_fields.xsd')"/>
    <xsl:variable name="MsgId" select="'ACSAMSTAT'"/>
    <xsl:variable name="OutDir" select="'../../../XSD/GoE_Schema/SeparateMessages/'"/>
    <xsl:template name="ExtractAllMessageSchema">
        <xsl:param name="outdir" select="$OutDir"/>
        <xsl:for-each select="$Msgs/xsd:schema/xsd:complexType[xsd:annotation/xsd:appinfo/*:Msg/@identifier]">
            <xsl:call-template name="ExtractMessageSchema">
                <xsl:with-param name="msgident" select="./xsd:annotation/xsd:appinfo/*:Msg/@identifier"/>
                <xsl:with-param name="outdir" select="$outdir"/>
            </xsl:call-template>
        </xsl:for-each>
    </xsl:template>
    <!--*****************************************************-->
    <xsl:template name="ExtractMessageSchema">
        <xsl:param name="msgident" select="$MsgId"/>
        <xsl:param name="outdir" select="$OutDir"/>
        <xsl:for-each select="$Msgs/xsd:schema/xsd:complexType[xsd:annotation/xsd:appinfo/*:Msg/@identifier = $msgident]">
            <xsl:variable name="elname" select="@name"/>
            <xsl:variable name="msgname" select="xsd:attribute[@name = 'mtfid']/@fixed"/>
            <xsl:variable name="mid" select="translate($msgname, ' .:', '')"/>
            <xsl:variable name="message">
                <xsl:copy-of select="."/>
                <xsl:copy-of select="$Msgs/xsd:schema/xsd:element[@type = $elname]"/>
            </xsl:variable>
            <xsl:variable name="segments">
                <!--List of all segments in message at any level - may be duplicates-->
                <xsl:variable name="seglist">
                    <xsl:for-each select="$message//@*[starts-with(., 'seg:')]">
                        <xsl:call-template name="getSegments">
                            <xsl:with-param name="segName" select="substring-after(., 'seg:')"/>
                        </xsl:call-template>
                    </xsl:for-each>
                </xsl:variable>
                <xsl:variable name="segnodelist">
                    <xsl:for-each select="$seglist/*">
                        <xsl:variable name="n" select="@name"/>
                        <xsl:if test="not(preceding-sibling::*/@name = $n)">
                            <xsl:copy-of select="$Segments/xsd:schema/*[@name = $n]"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:variable>
                <!--<xsl:copy-of select="$seglist"/>-->
                <xsl:for-each select="$segnodelist/xsd:complexType">
                    <xsl:sort select="@name"/>
                    <xsl:copy-of select="."/>
                </xsl:for-each>
                <xsl:for-each select="$segnodelist/xsd:element">
                    <xsl:sort select="@name"/>
                    <xsl:variable name="n" select="@name"/>
                    <xsl:copy-of select="."/>
                </xsl:for-each>
            </xsl:variable>
            <xsl:variable name="sets">
                <!--List of all sets in message at any level - will be duplicates-->
                <xsl:variable name="setlist">
                    <xsl:for-each select="$message//@*[starts-with(., 'set:')]">
                        <xsl:call-template name="getSets">
                            <xsl:with-param name="setName" select="substring-after(., 'set:')"/>
                        </xsl:call-template>
                    </xsl:for-each>
                    <xsl:for-each select="$segments//@*[starts-with(., 'set:')]">
                        <xsl:call-template name="getSets">
                            <xsl:with-param name="setName" select="substring-after(., 'set:')"/>
                        </xsl:call-template>
                    </xsl:for-each>
                </xsl:variable>
                <!--<xsl:copy-of select="$setlist"/>-->
                <xsl:variable name="setnodelist">
                    <xsl:for-each select="$setlist/*">
                        <xsl:variable name="n" select="@name"/>
                        <xsl:if test="not(preceding-sibling::*/@name = $n)">
                            <xsl:copy-of select="$Sets/xsd:schema/*[@name = $n]"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:variable>
                <xsl:for-each select="$setnodelist/xsd:complexType">
                    <xsl:copy-of select="."/>
                </xsl:for-each>
                <xsl:for-each select="$setnodelist/xsd:element">
                    <xsl:copy-of select="."/>
                </xsl:for-each>
            </xsl:variable>
            <xsl:variable name="fields">
                <xsl:variable name="fieldlist">
                    <xsl:for-each select="$message//@*[starts-with(., 'field:')]">
                        <xsl:call-template name="getFields">
                            <xsl:with-param name="fieldName" select="substring-after(., 'field:')"/>
                        </xsl:call-template>
                    </xsl:for-each>
                    <xsl:for-each select="$segments//@*[starts-with(., 'field:')]">
                        <xsl:call-template name="getFields">
                            <xsl:with-param name="fieldName" select="substring-after(., 'field:')"/>
                        </xsl:call-template>
                    </xsl:for-each>
                    <xsl:for-each select="$sets//@*[starts-with(., 'field:')]">
                        <xsl:call-template name="getFields">
                            <xsl:with-param name="fieldName" select="substring-after(., 'field:')"/>
                        </xsl:call-template>
                    </xsl:for-each>
                </xsl:variable>
                <!--<xsl:copy-of select="$fieldlist"/>-->
                <xsl:variable name="fnodelist">
                    <xsl:for-each select="$fieldlist/*">
                        <xsl:variable name="n" select="@name"/>
                        <xsl:if test="not(preceding-sibling::*/@name = $n)">
                            <xsl:copy-of select="$Fields/xsd:schema/*[@name = $n]"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:variable>
                <xsl:for-each select="$fnodelist/xsd:complexType">
                    <xsl:copy-of select="."/>
                </xsl:for-each>
                <xsl:for-each select="$fnodelist/xsd:element">
                    <xsl:copy-of select="."/>
                </xsl:for-each>
            </xsl:variable>
            <xsl:result-document href="{$outdir}/{$mid}/{concat($mid,'_message.xsd')}">
                <xsl:for-each select="$Msgs/xsd:schema">
                    <xsl:copy copy-namespaces="yes">
                        <xsl:apply-templates select="@*" mode="copy"/>
                        <xsl:apply-templates select="xsd:import" mode="copy">
                            <xsl:with-param name="msgid" select="$mid"/>
                            <xsl:with-param name="incseg" select="$segments//xsd:complexType"/>
                        </xsl:apply-templates>
                        <xsl:copy-of select="$message"/>
                    </xsl:copy>
                </xsl:for-each>
            </xsl:result-document>
            <!--Omit segments if no content-->
            <xsl:if test="$segments//xsd:complexType">
                <xsl:result-document href="{$outdir}/{$mid}/{concat($mid,'_segments.xsd')}">
                    <xsl:for-each select="$Segments/xsd:schema[1]">
                        <xsl:copy copy-namespaces="yes">
                            <xsl:apply-templates select="@*" mode="copy"/>
                            <xsl:apply-templates select="xsd:import" mode="copy">
                                <xsl:with-param name="msgid" select="$mid"/>
                            </xsl:apply-templates>
                            <xsl:copy-of select="$segments"/>
                        </xsl:copy>
                    </xsl:for-each>
                </xsl:result-document>
            </xsl:if>
            <xsl:result-document href="{$outdir}/{$mid}/{concat($mid,'_sets.xsd')}">
                <xsl:for-each select="$Sets/xsd:schema[1]">
                    <xsl:copy copy-namespaces="yes">
                        <xsl:apply-templates select="@*" mode="copy"/>
                        <xsl:apply-templates select="xsd:import" mode="copy">
                            <xsl:with-param name="msgid" select="$mid"/>
                        </xsl:apply-templates>
                        <xsl:copy-of select="$sets"/>
                    </xsl:copy>
                </xsl:for-each>
            </xsl:result-document>
            <xsl:result-document href="{$outdir}/{$mid}/{concat($mid,'_fields.xsd')}">
                <xsl:for-each select="$Fields/xsd:schema[1]">
                    <xsl:copy copy-namespaces="yes">
                        <xsl:apply-templates select="@*" mode="copy"/>
                        <xsl:apply-templates select="xsd:import" mode="copy">
                            <xsl:with-param name="msgid" select="$mid"/>
                        </xsl:apply-templates>
                        <xsl:copy-of select="$fields"/>
                    </xsl:copy>
                </xsl:for-each>
            </xsl:result-document>
        </xsl:for-each>
    </xsl:template>
    <!--*****************************************************-->
    <!--Return Global Segment name and any locally referenced segments-->
    <xsl:template name="getSegments">
        <xsl:param name="segName"/>
        <seg name="{$segName}"/>
        <xsl:variable name="seg" select="$Segments/xsd:schema/*[@name = $segName]"/>
        <xsl:for-each select="$seg//@*[name() = 'ref' or name() = 'type' or name() = 'base'][not(contains(., ':'))][not(. = $segName)]">
            <xsl:call-template name="getSegments">
                <xsl:with-param name="segName" select="."/>
            </xsl:call-template>
        </xsl:for-each>
    </xsl:template>
    <!--Return Global Set name and any locally referenced segments-->
    <xsl:template name="getSets">
        <xsl:param name="setName"/>
        <set name="{$setName}"/>
        <xsl:variable name="set" select="$Sets/xsd:schema/*[@name = $setName]"/>
        <xsl:for-each select="$set//@*[name() = 'ref' or name() = 'type' or name() = 'base'][not(contains(., ':'))][not(. = $setName)]">
            <xsl:call-template name="getSets">
                <xsl:with-param name="setName" select="."/>
            </xsl:call-template>
        </xsl:for-each>
    </xsl:template>
    <!--Return Global Set name and any locally referenced segments-->
    <xsl:template name="getFields">
        <xsl:param name="fieldName"/>
        <field name="{$fieldName}"/>
        <xsl:variable name="field" select="$Fields/xsd:schema/*[@name = $fieldName]"/>
        <xsl:for-each select="$field//@*[name() = 'ref' or name() = 'type' or name() = 'base'][not(contains(., ':'))][not(. = $fieldName)]">
            <xsl:call-template name="getFields">
                <xsl:with-param name="fieldName" select="."/>
            </xsl:call-template>
        </xsl:for-each>
    </xsl:template>
    <xsl:template match="*" mode="copy">
        <xsl:param name="msgid"/>
        <xsl:param name="incseg"/>
        <xsl:choose>
            <!--don't add segments xsd if no segments.-->
            <xsl:when test="ends-with(@namespace, 'segments') and not($incseg)"/>
            <xsl:otherwise>
                <xsl:copy copy-namespaces="no">
                    <xsl:apply-templates select="@*" mode="copy">
                        <xsl:with-param name="msgid" select="$msgid"/>
                        <xsl:with-param name="incseg" select="$incseg"/>
                    </xsl:apply-templates>
                    <xsl:apply-templates select="text()" mode="copy"/>
                    <xsl:apply-templates select="*" mode="copy">
                        <xsl:with-param name="msgid" select="$msgid"/>
                        <xsl:with-param name="incseg" select="$incseg"/>
                    </xsl:apply-templates>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="@schemaLocation" mode="copy">
        <xsl:param name="msgid"/>
        <xsl:param name="incseg"/>
        <xsl:choose>
            <xsl:when test=". = 'IC-ISM-v2.xsd'">
                <xsl:attribute name="schemaLocation">
                    <xsl:value-of select="concat('../', .)"/>
                </xsl:attribute>
            </xsl:when>
            <xsl:otherwise>
                <xsl:attribute name="schemaLocation">
                    <xsl:value-of select="concat($msgid, '_', substring-after(., '_'))"/>
                </xsl:attribute>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="@*" mode="copy">
        <xsl:copy-of select="."/>
    </xsl:template>
    <xsl:template match="text()" mode="copy">
        <xsl:value-of select="."/>
    </xsl:template>
    <xsl:template match="text()"/>
</xsl:stylesheet>
