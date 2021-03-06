<?xml version="1.0" encoding="UTF-8"?>
<!--
/* 
 * Copyright (C) 2015 JD NEUSHUL
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsd="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xsd"
    version="2.0">
    <xsl:output method="xml" indent="yes"/>
    <xsl:variable name="mtfmsgs" select="document('../../XSD/Baseline_Schema/messages.xsd')"/>
    <xsl:variable name="mtfsets" select="document('../../XSD/Baseline_Schema/sets.xsd')"/>
    <xsl:variable name="fields" select="document('../../XSD/GoE_Schema/GoE_fields.xsd')"/>
    <xsl:variable name="sets" select="document('../../XSD/GoE_Schema/GoE_sets.xsd')"/>
    <xsl:variable name="segments" select="document('../../XSD/GoE_Schema/GoE_segments.xsd')"/>
    <xsl:variable name="set_Changes" select="document('../../XSD/Deconflicted/Set_Name_Changes.xml')/USMTF_Sets"/>
    <xsl:variable name="segment_Changes" select="document('../../XSD/Deconflicted/Segment_Name_Changes.xml')/USMTF_Segments"/>
    <xsl:variable name="outputdoc" select="'../../XSD/GoE_Schema/GoE_messages.xsd'"/>
    <xsl:variable name="msgs">
        <xsl:apply-templates select="$mtfmsgs/xsd:schema/xsd:element" mode="el"/>
    </xsl:variable>
    <xsl:variable name="ctypes">
        <xsl:apply-templates select="$mtfmsgs/xsd:schema/xsd:element" mode="ctype"/>
    </xsl:variable>
    <!--*****************************************************-->
    <xsl:template name="main">
        <xsl:result-document href="{$outputdoc}">
            <xsd:schema xml:lang="en-US" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns="urn:mtf:mil:6040b:goe:mtf"
                targetNamespace="urn:mtf:mil:6040b:goe:mtf" xmlns:field="urn:mtf:mil:6040b:goe:fields" xmlns:set="urn:mtf:mil:6040b:goe:sets"
                xmlns:seg="urn:mtf:mil:6040b:goe:segments" xmlns:ism="urn:us:gov:ic:ism:v2" elementFormDefault="unqualified"
                attributeFormDefault="unqualified">
                <xsd:import namespace="urn:mtf:mil:6040b:goe:fields" schemaLocation="GoE_fields.xsd"/>
                <xsd:import namespace="urn:mtf:mil:6040b:goe:sets" schemaLocation="GoE_sets.xsd"/>
                <xsd:import namespace="urn:mtf:mil:6040b:goe:segments" schemaLocation="GoE_segments.xsd"/>
                <xsd:import namespace="urn:us:gov:ic:ism:v2" schemaLocation="IC-ISM-v2.xsd"/>
                <xsl:copy-of select="$ctypes"/>
                <xsl:copy-of select="$msgs"/>
            </xsd:schema>
        </xsl:result-document>
    </xsl:template>
    <!--*****************************************************-->
    <xsl:template match="xsd:schema/xsd:element" mode="el">
        <xsl:copy copy-namespaces="no">
            <xsl:attribute name="name">
                <xsl:value-of select="@name"/>
            </xsl:attribute>
            <xsl:attribute name="type">
                <xsl:value-of select="concat(@name, 'Type')"/>
            </xsl:attribute>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="xsd:element/xsd:annotation" mode="el">
        <xsl:copy copy-namespaces="no">
            <xsl:apply-templates select="*" mode="el"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="xsd:documentation" mode="el">
        <xsl:copy copy-namespaces="no">
            <xsl:value-of select="normalize-space(.)"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="xsd:schema/xsd:element/xsd:annotation/xsd:appinfo" mode="el">
        <xsl:copy copy-namespaces="no">
            <Msg>
                <xsl:apply-templates select="*[not(name() = 'MtfStructuralRelationship')]" mode="attr"/>
                <xsl:apply-templates select="*:MtfRelatedDocument" mode="doc"/>
            </Msg>
            <xsl:apply-templates select="*[name() = 'MtfStructuralRelationship']" mode="attr"/>
        </xsl:copy>
    </xsl:template>
    <!--Include Rules as attribute strings.  Replace double quotes with single quotes-->
    <xsl:template match="*[name() = 'MtfStructuralRelationship']" mode="attr">
        <!--OMIT RULES ENFORCED BY ASSIGNED FIXED VALUES-->
        <xsl:choose>
            <xsl:when test="starts-with(*:MtfStructuralRelationshipRule/text(), '[3]F1')"/>
            <xsl:when test="starts-with(*:MtfStructuralRelationshipRule/text(), '[3]F2')"/>
            <xsl:when test="starts-with(*:MtfStructuralRelationshipRule/text(), '[3]F3')"/>
            <xsl:when test="starts-with(*:MtfStructuralRelationshipExplanation/text(), 'Field 1 In GENTEXT')"/>
            <xsl:when test="starts-with(*:MtfStructuralRelationshipExplanation/text(), 'Field 1 in GENTEXT')"/>
            <xsl:when test="starts-with(*:MtfStructuralRelationshipExplanation/text(), 'Field 1 IN GENTEXT')"/>
            <xsl:when test="starts-with(*:MtfStructuralRelationshipExplanation/text(), 'Field 1 in the GENTEXT')"/>
            <xsl:when test="starts-with(*:MtfStructuralRelationshipExplanation/text(), 'Field 1 of GENTEXT')"/>
            <xsl:when test="starts-with(*:MtfStructuralRelationshipExplanation/text(), 'Field 1 in HEADING')"/>
            <xsl:when test="starts-with(*:MtfStructuralRelationshipExplanation/text(), 'Field 1 of HEADING')"/>
            <xsl:otherwise>
                <xsl:element name="Rule">
                    <xsl:apply-templates select="*[string-length(text()[1]) > 0]" mode="trimattr"/>
                </xsl:element>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="*" mode="trimattr">
        <xsl:variable name="apos">&#39;</xsl:variable>
        <xsl:variable name="quot">&#34;</xsl:variable>
        <xsl:variable name="nm" select="lower-case(substring-after(name(), 'MtfStructuralRelationship'))"/>
        <xsl:choose>
            <xsl:when test="$nm='rule'">
                <xsl:attribute name="structure">
                    <xsl:value-of select="normalize-space(translate(replace(., $quot, $apos),'&#xA;',''))" disable-output-escaping="yes"/>
                </xsl:attribute>
            </xsl:when>
            <xsl:otherwise>
                <xsl:attribute name="{$nm}">
                    <xsl:value-of select="normalize-space(translate(replace(., $quot, $apos),'&#xA;',''))" disable-output-escaping="yes"/> 
                </xsl:attribute>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="xsd:schema/xsd:element" mode="ctype">
        <xsd:complexType name="{concat(@name,'Type')}">
            <xsl:apply-templates select="@*" mode="ctype"/>
            <xsl:apply-templates select="xsd:annotation" mode="el"/>
            <xsl:apply-templates select="*[not(name() = 'xsd:annotation')]" mode="ctype"/>
        </xsd:complexType>
    </xsl:template>
    <xsl:template match="xsd:schema/xsd:element/@name" mode="ctype"/>
    <xsl:template match="xsd:schema/xsd:element/xsd:annotation/xsd:appinfo" mode="ctype"/>
    <xsl:template match="xsd:element" mode="ctype">
        <xsl:variable name="elname">
            <xsl:choose>
                <xsl:when test="starts-with(@name, '_')">
                    <xsl:value-of select="@name"/>
                </xsl:when>
                <xsl:when test="contains(@name, '_')">
                    <xsl:value-of select="substring-before(@name, '_')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="@name"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="setid">
            <xsl:value-of
                select="$mtfsets/xsd:schema/xsd:complexType[@name = concat($elname, 'Type')]/xsd:annotation/xsd:appinfo/*:SetFormatIdentifier"/>
        </xsl:variable>
        <xsl:variable name="newname">
            <xsl:choose>
                <xsl:when test="$setid = '1APHIB'">
                    <xsl:text>AmphibiousForceCompositionSet</xsl:text>
                </xsl:when>
                <xsl:when test="$setid = 'MARACT'">
                    <xsl:text>MaritimeActivitySet</xsl:text>
                </xsl:when>
                <xsl:when test="exists($set_Changes/Set[@SETNAMESHORT = $setid and string-length(@ProposedSetFormatName) > 0])">
                    <xsl:value-of
                        select="concat(translate($set_Changes/Set[@SETNAMESHORT = $setid and string-length(@ProposedSetFormatName) > 0][1]/@ProposedSetFormatName, ' ,/-()', ''),'Set')"
                    />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="concat($elname,'Set')"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:choose>
            <!--DECONFLICT SPECIFICS-->
            <xsl:when test="$newname = 'ShipPositionAndMovement' and contains(xsd:annotation/xsd:documentation, '1SHIPARR')">
                <xsl:copy copy-namespaces="no">
                    <xsl:attribute name="name">
                        <xsl:text>ShipPositionAndMovementArrivalSet</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="type">
                        <xsl:text>set:ShipPositionAndMovementSetType</xsl:text>
                    </xsl:attribute>
                    <xsl:apply-templates select="@*[not(name() = 'name')][not(name() = 'type')]" mode="ctype"/>
                    <xsl:apply-templates select="xsd:annotation" mode="ctype"/>
                </xsl:copy>
            </xsl:when>
            <xsl:when test="$newname = 'ShipPositionAndMovementSet' and contains(xsd:annotation/xsd:documentation, '1SHIPDEP')">
                <xsl:copy copy-namespaces="no">
                    <xsl:attribute name="name">
                        <xsl:text>ShipPositionAndMovementDepartureSet</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="type">
                        <xsl:text>set:ShipPositionAndMovementSetType</xsl:text>
                    </xsl:attribute>
                    <xsl:apply-templates select="@*[not(name() = 'name')][not(name() = 'type')]" mode="ctype"/>
                    <xsl:apply-templates select="xsd:annotation" mode="ctype"/>
                </xsl:copy>
            </xsl:when>
            <xsl:when test="exists($sets/xsd:schema/xsd:element[@name = $newname])">
                <xsl:copy copy-namespaces="no">
                    <xsl:attribute name="ref">
                        <xsl:value-of select="concat('set:', $newname)"/>
                    </xsl:attribute>
                    <xsl:apply-templates select="@*[not(name() = 'name')]" mode="ctype"/>
                    <xsl:apply-templates select="xsd:annotation" mode="ctype"/>
                </xsl:copy>
            </xsl:when>
            <xsl:when test="starts-with(./xsd:complexType/xsd:complexContent/xsd:extension/@base, 's:')">
                <xsl:variable name="b" select="./xsd:complexType/xsd:complexContent/xsd:extension/@base"/>
                <xsl:variable name="bsettype">
                    <xsl:value-of select="concat(substring($b,0,string-length($b)-3),'SetType')"/>
                </xsl:variable>
                <xsl:copy copy-namespaces="no">
                    <xsl:attribute name="name">
                        <xsl:value-of select="$newname"/>
                    </xsl:attribute>
                    <xsl:attribute name="type">
                        <xsl:value-of select="replace($bsettype, 's:', 'set:')"/>
                    </xsl:attribute>
                    <xsl:apply-templates select="@*[not(name() = 'name')]" mode="ctype"/>
                    <xsl:apply-templates select="xsd:annotation" mode="ctype"/>
                </xsl:copy>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy copy-namespaces="no">
                    <xsl:apply-templates select="@*" mode="ctype"/>
                    <xsl:apply-templates select="*" mode="ctype"/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="xsd:element[xsd:annotation/xsd:appinfo/*:SegmentStructureName]" mode="ctype">
        <xsl:variable name="elname">
            <xsl:value-of select="@name"/>
        </xsl:variable>
        <xsl:variable name="mtfid">
            <xsl:value-of select="ancestor::xsd:element[parent::xsd:schema]/xsd:annotation/xsd:appinfo/*:MtfIdentifier"/>
        </xsl:variable>
        <xsl:variable name="newname">
            <xsl:choose>
                <xsl:when test="exists($segment_Changes/Segment[@MTF_NAME = $mtfid and @SegmentElement = $elname])">
                    <xsl:value-of select="$segment_Changes/Segment[@MTF_NAME = $mtfid and @SegmentElement = $elname]/@ProposedSegmentElement"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$elname"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="exists($segments/xsd:schema/xsd:element[@name = $newname])">
                <xsl:copy copy-namespaces="no">
                    <xsl:attribute name="ref">
                        <xsl:value-of select="concat('seg:', $newname)"/>
                    </xsl:attribute>
                    <xsl:apply-templates select="@*[not(name() = 'name')]" mode="ctype"/>
                    <xsl:apply-templates select="xsd:annotation" mode="ctype"/>
                </xsl:copy>
            </xsl:when>
            <xsl:when test="exists($segments/xsd:schema/xsd:element[@name = $elname])">
                <xsl:copy copy-namespaces="no">
                    <xsl:attribute name="ref">
                        <xsl:value-of select="concat('seg:', $elname)"/>
                    </xsl:attribute>
                    <xsl:apply-templates select="@*[not(name() = 'name')]" mode="ctype"/>
                    <xsl:apply-templates select="xsd:annotation" mode="ctype"/>
                </xsl:copy>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy copy-namespaces="no">
                    <xsl:apply-templates select="@*" mode="ctype"/>
                    <xsl:apply-templates select="*" mode="ctype"/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="xsd:element[starts-with(@name, 'GeneralText')]" mode="ctype">
        <xsl:variable name="per">&#46;</xsl:variable>
        <xsl:variable name="apos">&#34;</xsl:variable>
        <xsl:variable name="lparen">&#40;</xsl:variable>
        <xsl:variable name="rparen">&#41;</xsl:variable>
        <xsl:variable name="UseDesc">
            <xsl:value-of select="normalize-space(translate(upper-case(xsd:annotation/xsd:appinfo/*:SetFormatPositionUseDescription), '.', ''))"/>
        </xsl:variable>
        <xsl:variable name="TextInd">
            <xsl:value-of select="normalize-space(substring-after($UseDesc, 'MUST EQUAL'))"/>
        </xsl:variable>
        <xsl:variable name="CCase">
            <xsl:call-template name="CamelCase">
                <xsl:with-param name="text">
                    <xsl:value-of select="replace($TextInd, $apos, '')"/>
                </xsl:with-param>
            </xsl:call-template>
        </xsl:variable>
        <xsl:copy copy-namespaces="no">
            <!--<xsl:apply-templates select="@*"/>-->
            <!--handle 2 special cases with parens-->
            <xsl:attribute name="name">
                <!--GENTEXT NAME DECONFLICTION-->
                <xsl:choose>
                    <xsl:when
                        test="contains(xsd:annotation/xsd:documentation, 'GENTEXT/ACSIGN') and contains(xsd:annotation/xsd:documentation, 'airborne')">
                        <xsl:text>GenTextAirborneAcsign</xsl:text>
                    </xsl:when>
                    <xsl:when
                        test="contains(xsd:annotation/xsd:documentation, 'GENTEXT/ACSIGN') and contains(xsd:annotation/xsd:documentation, 'ground')">
                        <xsl:text>GenTextGroundAcsign</xsl:text>
                    </xsl:when>
                    <xsl:when
                        test="contains(xsd:annotation/xsd:documentation, 'GENTEXT/ACSIGN') and contains(xsd:annotation/xsd:documentation, 'shipborne')">
                        <xsl:text>GenTextShipborneAcsign</xsl:text>
                    </xsl:when>
                    <xsl:when
                        test="contains(xsd:annotation/xsd:documentation, 'GENTEXT/ARCHITECTURE') and contains(xsd:annotation/xsd:documentation, 'BGDBM')">
                        <xsl:text>GenTextBGDBMArchitectureConfigurationAmplification</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="translate(concat('GenText', replace(replace($CCase, '(TAS)', ''), '(mpa)', '')), ' ,/”()', '')"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:element name="xsd:annotation">
                <xsl:apply-templates select="xsd:annotation/*" mode="ctype"/>
            </xsl:element>
            <xsd:complexType>
                <xsd:complexContent>
                    <xsd:extension base="set:GeneralTextSetType">
                        <xsd:sequence>
                            <xsd:element name="GentextTextIndicator" type="field:AlphaNumericBlankSpecialTextType" minOccurs="1"
                                fixed="{translate(replace($TextInd,$apos,''),'”','')}"/>
                            <xsd:element ref="field:FreeTextField" minOccurs="1"/>
                        </xsd:sequence>
                    </xsd:extension>
                </xsd:complexContent>
            </xsd:complexType>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="xsd:element[starts-with(@name, 'HeadingInformation')]" mode="ctype">
        <xsl:variable name="per">&#46;</xsl:variable>
        <xsl:variable name="apos">&#34;</xsl:variable>
        <xsl:variable name="lparen">&#40;</xsl:variable>
        <xsl:variable name="rparen">&#41;</xsl:variable>
        <xsl:variable name="UseDesc">
            <xsl:value-of select="normalize-space(translate(upper-case(xsd:annotation/xsd:appinfo/*:SetFormatPositionUseDescription), '.', ''))"/>
        </xsl:variable>
        <xsl:variable name="TextInd">
            <xsl:value-of select="normalize-space(substring-after($UseDesc, 'MUST EQUAL'))"/>
        </xsl:variable>
        <xsl:variable name="CCase">
            <xsl:call-template name="CamelCase">
                <xsl:with-param name="text">
                    <xsl:value-of select="replace($TextInd, $apos, '')"/>
                </xsl:with-param>
            </xsl:call-template>
        </xsl:variable>
        <xsl:copy copy-namespaces="no">
            <!--<xsl:apply-templates select="@*"/>-->
            <!--handle 2 special cases with parens-->
            <xsl:attribute name="name">
                <xsl:value-of select="translate(concat('HeadingInformation', replace(replace($CCase, '(TAS)', ''), '(mpa)', '')), ' ,/”()', '')"/>
            </xsl:attribute>
            <xsl:element name="xsd:annotation">
                <xsl:apply-templates select="xsd:annotation/*" mode="ctype"/>
            </xsl:element>
            <xsd:complexType>
                <xsd:complexContent>
                    <xsd:extension base="set:HeadingInformationSetType">
                        <xsd:sequence>
                            <xsd:element name="FieldAssignment" type="field:AlphaNumericBlankSpecialTextType" minOccurs="1"
                                fixed="{translate(replace($TextInd,$apos,''),'”','')}"/>
                            <xsd:element ref="field:FreeTextField" minOccurs="1"/>
                        </xsd:sequence>
                    </xsd:extension>
                </xsd:complexContent>
            </xsd:complexType>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="xsd:schema/xsd:element/xsd:complexType" mode="ctype">
        <xsl:apply-templates select="@*" mode="ctype"/>
        <xsl:apply-templates select="*" mode="ctype"/>
    </xsl:template>
    <xsl:template match="*" mode="ctype">
        <xsl:copy copy-namespaces="no">
            <xsl:apply-templates select="@*" mode="ctype"/>
            <xsl:apply-templates select="*" mode="ctype"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="xsd:documentation" mode="ctype">
        <xsl:copy copy-namespaces="no">
            <xsl:apply-templates select="text()" mode="ctype"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="xsd:complexType/xsd:sequence/xsd:choice/xsd:annotation/xsd:appinfo" mode="ctype"/>
    <xsl:template match="xsd:appinfo" mode="ctype">
        <xsl:copy copy-namespaces="no">
            <xsl:choose>
                <xsl:when test="child::node()[starts-with(name(), 'Set')]">
                    <Set>
                        <xsl:apply-templates select="*[string-length(text()) > 0]" mode="attr"/>
                    </Set>
                </xsl:when>
                <xsl:when test="child::node()[starts-with(name(), 'Segment')]">
                    <Segment>
                        <xsl:apply-templates select="*[string-length(text()) > 0]" mode="attr"/>
                    </Segment>
                </xsl:when>
            </xsl:choose>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="@base" mode="ctype">
        <xsl:attribute name="base">
            <xsl:value-of select="replace(., 's:', 'set:')"/>
        </xsl:attribute>
    </xsl:template>
    <xsl:template match="*" mode="attr">
        <xsl:variable name="apos">
            <xsl:text>&apos;</xsl:text>
        </xsl:variable>
        <xsl:variable name="quot">
            <xsl:text>&quot;</xsl:text>
        </xsl:variable>
        <xsl:if test="string-length(text()) != 0">
            <xsl:attribute name="{name()}">
                <xsl:value-of select="replace(normalize-space(.), $quot, $apos)"/>
            </xsl:attribute>
        </xsl:if>
    </xsl:template>
    <xsl:template name="CamelCase">
        <xsl:param name="text"/>
        <xsl:choose>
            <xsl:when test="contains($text, ' ')">
                <xsl:call-template name="CamelCaseWord">
                    <xsl:with-param name="text" select="substring-before($text, ' ')"/>
                </xsl:call-template>
                <xsl:text> </xsl:text>
                <xsl:call-template name="CamelCase">
                    <xsl:with-param name="text" select="substring-after($text, ' ')"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="CamelCaseWord">
                    <xsl:with-param name="text" select="$text"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template name="CamelCaseWord">
        <xsl:param name="text"/>
        <xsl:value-of select="translate(substring($text, 1, 1), 'abcdefghijklmnopqrstuvwxyz', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ')"/>
        <xsl:value-of select="translate(substring($text, 2, string-length($text) - 1), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')"/>
    </xsl:template>
    <xsl:template match="*:InitialSetFormatPosition" mode="attr"/>
    <!--Use Position relative to segment vice position relative to containing message-->
    <xsl:template match="*:SegmentStructureName" mode="attr">
        <xsl:if test="not(normalize-space(text()) = ' ') and not(*) and not(normalize-space(text()) = '')">
            <xsl:attribute name="name">
                <xsl:apply-templates select="text()"/>
            </xsl:attribute>
        </xsl:if>
    </xsl:template>
    <xsl:template match="*:SegmentStructureConcept" mode="attr">
        <xsl:if test="not(normalize-space(text()) = ' ') and not(*) and not(normalize-space(text()) = '')">
            <xsl:attribute name="concept">
                <xsl:apply-templates select="text()"/>
            </xsl:attribute>
        </xsl:if>
    </xsl:template>
    <xsl:template match="*:SegmentStructureUseDescription" mode="attr">
        <xsl:if test="not(normalize-space(text()) = ' ') and not(*) and not(normalize-space(text()) = '')">
            <xsl:attribute name="usage">
                <xsl:apply-templates select="text()"/>
            </xsl:attribute>
        </xsl:if>
    </xsl:template>
    <xsl:template match="*:SetFormatPositionUseDescription" mode="attr">
        <xsl:if test="not(normalize-space(text()) = ' ') and not(*) and not(normalize-space(text()) = '')">
            <xsl:attribute name="usage">
                <xsl:apply-templates select="text()"/>
            </xsl:attribute>
        </xsl:if>
    </xsl:template>
    <xsl:template match="*:SetFormatPositionName" mode="attr">
        <xsl:if test="not(normalize-space(text()) = ' ') and not(*) and not(normalize-space(text()) = '')">
            <xsl:attribute name="positionName">
                <xsl:apply-templates select="text()"/>
            </xsl:attribute>
        </xsl:if>
    </xsl:template>
    <xsl:template match="*:SetFormatPositionNumber" mode="attr">
        <xsl:if test="not(normalize-space(text()) = ' ') and not(*) and not(normalize-space(text()) = '')">
            <xsl:attribute name="position">
                <xsl:apply-templates select="text()"/>
            </xsl:attribute>
        </xsl:if>
    </xsl:template>
    <xsl:template match="*:SetFormatPositionConcept" mode="attr">
        <xsl:if test="not(normalize-space(text()) = ' ') and not(*) and not(normalize-space(text()) = '')">
            <xsl:attribute name="concept">
                <xsl:apply-templates select="text()"/>
            </xsl:attribute>
        </xsl:if>
    </xsl:template>
    <xsl:template match="*:MtfName" mode="attr">
        <xsl:if test="not(normalize-space(text()) = ' ') and not(*) and not(normalize-space(text()) = '')">
            <xsl:attribute name="name">
                <xsl:apply-templates select="text()"/>
            </xsl:attribute>
        </xsl:if>
    </xsl:template>
    <xsl:template match="*:MtfIdentifier" mode="attr">
        <xsl:if test="not(normalize-space(text()) = ' ') and not(*) and not(normalize-space(text()) = '')">
            <xsl:attribute name="identifier">
                <xsl:apply-templates select="text()"/>
            </xsl:attribute>
        </xsl:if>
    </xsl:template>
    <xsl:template match="*:MtfSponsor" mode="attr">
        <xsl:if test="not(normalize-space(text()) = ' ') and not(*) and not(normalize-space(text()) = '')">
            <xsl:attribute name="sponsor">
                <xsl:apply-templates select="text()"/>
            </xsl:attribute>
        </xsl:if>
    </xsl:template>
    <xsl:template match="*:MtfPurpose" mode="attr">
        <xsl:if test="not(normalize-space(text()) = ' ') and not(*) and not(normalize-space(text()) = '')">
            <xsl:attribute name="purpose">
                <xsl:apply-templates select="text()"/>
            </xsl:attribute>
        </xsl:if>
    </xsl:template>
    <xsl:template match="*:VersionIndicator" mode="attr">
        <xsl:if test="not(normalize-space(text()) = ' ') and not(*) and not(normalize-space(text()) = '')">
            <xsl:attribute name="version">
                <xsl:apply-templates select="text()"/>
            </xsl:attribute>
        </xsl:if>
    </xsl:template>
    <xsl:template match="*:MtfNote" mode="attr">
        <xsl:if test="not(normalize-space(text()) = ' ') and not(*) and not(normalize-space(text()) = '')">
            <xsl:attribute name="note">
                <xsl:apply-templates select="text()"/>
            </xsl:attribute>
        </xsl:if>
    </xsl:template>
    <xsl:template match="*:MtfRelatedDocument" mode="doc">
        <xsl:if test="not(normalize-space(text()) = ' ') and not(*) and not(normalize-space(text()) = '') and not(normalize-space(text()) = 'NONE')">
            <xsl:if test="not(preceding-sibling::*:MtfRelatedDocument)">
                <xsl:element name="Document" namespace="urn:mtf:mil:6040b:goe:mtf">
                    <xsl:apply-templates select="text()"/>
                </xsl:element>
                <xsl:for-each select="following-sibling::*:MtfRelatedDocument">
                    <xsl:element name="Document" namespace="urn:mtf:mil:6040b:goe:mtf">
                        <xsl:apply-templates select="text()"/>
                    </xsl:element>
                </xsl:for-each>
            </xsl:if>
        </xsl:if>
    </xsl:template>
    <xsl:template match="*:MtfRelatedDocument" mode="attr"/>
    <xsl:template match="*:OccurrenceCategory" mode="attr"/>
    <xsl:template match="*:Repeatability" mode="attr"/>
    <xsl:template match="*:MtfIndexReferenceNumber" mode="attr"/>
    <!--*************** Message Identifier Fixed Values **********************-->
    <xsl:template match="xsd:element[@name = 'MessageIdentifier']" mode="ctype">
        <xsl:variable name="msgid" select="ancestor::xsd:complexType/xsd:attribute[@name = 'mtfid']/@fixed"/>
        <xsd:element name="MessageIdentifier">
            <xsl:apply-templates select="@*" mode="msgid"/>
            <xsl:apply-templates select="$sets/xsd:schema/xsd:complexType[@name = 'MessageIdentifierSetType']/xsd:annotation" mode="msgid"/>
            <xsd:complexType>
                <xsl:apply-templates select="$sets/xsd:schema/xsd:complexType[@name = 'MessageIdentifierSetType']/*[not(name() = 'xsd:annotation')]"
                    mode="msgid">
                    <xsl:with-param name="msgid" select="$msgid"/>
                </xsl:apply-templates>
            </xsd:complexType>
        </xsd:element>
    </xsl:template>
    <xsl:template match="*" mode="msgid">
        <xsl:param name="msgid"/>
        <xsl:copy copy-namespaces="no">
            <xsl:apply-templates select="@*" mode="msgid"/>
            <xsl:apply-templates select="*" mode="msgid">
                <xsl:with-param name="msgid" select="$msgid"/>
            </xsl:apply-templates>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="xsd:documentation" mode="msgid">
        <xsl:if test="string-length(text()) > 0">
            <xsl:copy-of select="." copy-namespaces="no"/>
        </xsl:if>
    </xsl:template>
    <xsl:template match="*:Example" mode="msgid"/>
    <xsl:template match="*:Set" mode="msgid">
        <xsl:element name="Set" namespace="urn:mtf:mil:6040b:goe:mtf">
            <xsl:apply-templates select="@*" mode="msgid"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="*:Field" mode="msgid">
        <xsl:element name="Set" namespace="urn:mtf:mil:6040b:goe:mtf">
            <xsl:apply-templates select="@*" mode="msgid"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="@base[. = 'SetBaseType']" mode="msgid">
        <xsl:attribute name="base">
            <xsl:text>set:SetBaseType</xsl:text>
        </xsl:attribute>
    </xsl:template>
    <xsl:template match="*[@name = 'MessageTextFormatIdentifierType']" mode="msgid"/>
    <xsl:template match="*[@name = 'VersionOfMessageTextFormat']" mode="msgid">
        <xsl:param name="msgid"/>
        <xsd:element name="MessageTextFormatIdentifier" type="field:AlphaNumericBlankSpecialTextType" minOccurs="1" maxOccurs="1" nillable="true"
            fixed="{$msgid}">
            <xsd:annotation>
                <xsd:appinfo>
                    <Set name="MESSAGE TEXT FORMAT IDENTIFIER" position="1" identifier="A" concept="The identifier of a message or report."/>
                </xsd:appinfo>
            </xsd:annotation>
        </xsd:element>
        <xsd:element name="Version" type="field:VersionOfMessageTextFormatType" minOccurs="1" maxOccurs="1" nillable="true" fixed="B.1.01.12">
            <xsd:annotation>
                <xsd:appinfo>
                    <Set name="VERSION OF MESSAGE TEXT FORMAT" position="2" identifier="A"
                        concept="The version of the message text format. The message version consists of four parts: Part 1 is the edition letter                 of MIL-STD-6040(SERIES), e.g., A, B, C through Z, Part 2 is the change number of the edition (0-5), Part 3 is the major change for the                 message, e.g., 01-99, and Part 4 is the minor change for the message, e.g., 00-99."
                    />
                </xsd:appinfo>
            </xsd:annotation>
        </xsd:element>
    </xsl:template>
    <xsl:template match="*[@name = 'StandardOfMessageTextFormat']" mode="msgid">
        <xsd:element name="Standard" type="field:AlphaNumericBlankSpecialInitDataLoadIDType" minOccurs="1" maxOccurs="1" nillable="true"
            fixed="MIL-STD-6040(SERIES)">
            <xsd:annotation>
                <xsd:appinfo>
                    <Set name="STANDARD OF MESSAGE TEXT FORMAT" position="3" identifier="A"
                        definition="The military standard that contains the message format rules."/>
                </xsd:appinfo>
            </xsd:annotation>
        </xsd:element>
    </xsl:template>
    <xsl:template match="@*" mode="ctype">
        <xsl:copy-of select="."/>
    </xsl:template>
    <xsl:template match="@*" mode="msgid">
        <xsl:copy-of select="."/>
    </xsl:template>
    <xsl:template match="text()">
        <xsl:value-of select="normalize-space(translate(., '&#34;&#xA;', ''))"/>
    </xsl:template>
    <xsl:template match="text()" mode="msgid">
        <xsl:value-of select="normalize-space(translate(., '&#34;&#xA;', ''))"/>
    </xsl:template>
    <xsl:template match="text()" mode="ctype">
        <xsl:value-of select="translate(normalize-space(.), '&#34;&#xA;', '')"/>
    </xsl:template>
</xsl:stylesheet>
