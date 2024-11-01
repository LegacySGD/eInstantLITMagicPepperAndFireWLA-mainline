<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:x="anything">
	<xsl:namespace-alias stylesheet-prefix="x" result-prefix="xsl" />
	<xsl:output encoding="UTF-8" indent="yes" method="xml" />
	<xsl:include href="../utils.xsl" />

	<xsl:template match="/Paytable">
		<x:stylesheet version="1.0" xmlns:java="http://xml.apache.org/xslt/java" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
			exclude-result-prefixes="java" xmlns:lxslt="http://xml.apache.org/xslt" xmlns:my-ext="ext1" extension-element-prefixes="my-ext">
			<x:import href="HTML-CCFR.xsl" />
			<x:output indent="no" method="xml" omit-xml-declaration="yes" />

			<!-- TEMPLATE Match: -->
			<x:template match="/">
				<x:apply-templates select="*" />
				<x:apply-templates select="/output/root[position()=last()]" mode="last" />
				<br />
			</x:template>

			<!--The component and its script are in the lxslt namespace and define the implementation of the extension. -->
			<lxslt:component prefix="my-ext" functions="formatJson,retrievePrizeTable,getType">
				<lxslt:script lang="javascript">
					<![CDATA[
					var debugFeed = [];
					var debugFlag = false;
					var bonusTotal = 0; 
					// Format instant win JSON results.
					// @param jsonContext String JSON results to parse and display.
					// @param translation Set of Translations for the game.
					function formatJson(jsonContext, translations, prizeTable, prizeValues, prizeNamesDesc)
					{
						var scenario = getScenario(jsonContext);
						var outcomeNums = getOutcomeData(scenario);
						var prizeNames = (prizeNamesDesc.substring(1)).split(',');
						var convertedPrizeValues = (prizeValues.substring(1)).split('|');

						// Output winning numbers table.
						var tierWinCount = 0;
						var booleanBonusGame = false;
						var bonusWinCount = 4;
						var r = [];

						// Output outcome numbers table.
 						r.push('<table border="0" cellpadding="2" cellspacing="1" class="gameDetailsTable">');
						r.push('<tr>');
 						r.push('<td class="tablehead" style="padding-right:10px">' + getTranslationByName("mainGame", translations) + '</td>');
 						r.push('<td class="tablehead" style="padding-right:10px">' + getTranslationByName("column", translations) + " 1" + '</td>');
 						r.push('<td class="tablehead" style="padding-right:10px">' + getTranslationByName("column", translations) + " 2" + '</td>');
 						r.push('<td class="tablehead" style="padding-right:10px">' + getTranslationByName("column", translations) + " 3" + '</td>');
 						r.push('<td class="tablehead" style="padding-right:10px">' + getTranslationByName("column", translations) + " 4" + '</td>');
 						r.push('<td class="tablehead" style="padding-right:10px">' + getTranslationByName("column", translations) + " 5" + '</td>');
 						r.push('</tr>');

						tierWinCount = [0,0,0,0,0];
						for(var i = 0; i < 5; ++i)
						{
							r.push('<tr>');
							r.push('<td>');
							r.push('</td>');
							for(var j = 0; j < 5; ++j) 
							{
								r.push('<td class="tablebody" style="padding-right:10px">');
								
								if ((i == 0 && j < 4) || (i == 1 && j < 3) || (i == 2 && j < 2) || (i == 3 && j < 1))
								{
									//r.push('.');
								}
								else if (outcomeNums[j][j+i-4][0] == '0') // represents the Win symbol.
								{
									++tierWinCount[j];
									r.push(getTranslationByName(outcomeNums[j][j+i-4][0], translations) + '<br/>' + convertedPrizeValues[getPrizeNameIndex(prizeNames, outcomeNums[j][j+i-4][1])]);
								}
								else if (outcomeNums[j][j+i-4][0] == '9') // represents the Bonus Trigger symbol
								{
									booleanBonusGame = true;
									r.push(getTranslationByName("bonusTrigger", translations));
								}
								else
								{
 									r.push(getTranslationByName(outcomeNums[j][j+i-4][0], translations));
								}
 								r.push('</td>');
							}
 							r.push('</tr>');
						}		
						r.push('<tr>')
						r.push('<td>');
						r.push('</td>');
						for(var i = 0; i < 5; ++i)
						{
							if (tierWinCount[i] == outcomeNums[i].length)
							{
								r.push('<td class="tablebody" style="padding-right:10px">' + tierWinCount[i] + 'x ' + getTranslationByName("multiplierAwarded", translations) + '</td>');
							}
							else
							{
								r.push('<td>');
								r.push('</td>');
							}
						}
						r.push('</tr>')
						r.push('</table>');

						if (booleanBonusGame)
						{
							var outcomeBonusGame = getBonusData(scenario);
							var bonusWin = '';
							var multiplierCount = 1;
							var wCount = 0;
							var xCount = 0;
							var yCount = 0;
							var zCount = 0;
							for(var i = 0; i < outcomeBonusGame.length; ++i)
							{
								if (outcomeBonusGame[i] == 'W') // represents the symbol B1
								{
									wCount++;
									if (wCount == bonusWinCount)
									{
										bonusWin = outcomeBonusGame[i];
									}
								}
								else if (outcomeBonusGame[i] == 'X') // represents the symbol B2
								{
									xCount++;
									if (xCount == bonusWinCount)
										bonusWin = outcomeBonusGame[i];
								}
								else if (outcomeBonusGame[i] == 'Y') // represents the symbol B3
								{
									yCount++;
									if (yCount == bonusWinCount)
										bonusWin = outcomeBonusGame[i];
								}
								else if (outcomeBonusGame[i] == 'Z') // represents the symbol B4
								{
									zCount++;
									if (zCount == bonusWinCount)
										bonusWin = outcomeBonusGame[i];
								}
								else
								{
									for(var j = 0; j < outcomeBonusGame[i]; ++j)
									{
										multiplierCount++;
									}
								}
							}

							r.push('&nbsp;');
							r.push('<table border="0" cellpadding="2" cellspacing="1" class="gameDetailsTable">');
							r.push('<tr>');
							r.push('<td class="tablehead" style="padding-right:10px">' + getTranslationByName("bonusGame", translations) + '</td>');
							r.push('</tr>');

							for(var i = 0; i < outcomeBonusGame.length; ++i)
							{
								r.push('<tr>');
								r.push('<td class="tablebody" style="padding-right:10px">' + getTranslationByName("pick", translations) + '  ' + (i+1) + '</td>');
								r.push('<td class="tablebody" style="padding-right:10px">');
								var regExTurn = outcomeBonusGame[i].replace(/[0-9]/g, '');
								if (regExTurn.length > 0)
								{
									r.push(getTranslationByName(outcomeBonusGame[i], translations) + ' ' + getTranslationByName("meterSymbol", translations));
								}
								else 
								{
									r.push('+' + outcomeBonusGame[i] + 'x ' + getTranslationByName("multiplier", translations));
								}
								r.push('</td>');
								r.push('</tr>');
							}
							r.push('</table>');

							r.push('&nbsp;');
							r.push('<table border="0" cellpadding="2" cellspacing="1" class="gameDetailsTable">');
							r.push('<tr>');
							r.push('<td class="tablebody" style="padding-right:10px">' + getTranslationByName(bonusWin, translations) + ' ' + getTranslationByName("meterAwarded", translations) + ' - ' + convertedPrizeValues[getPrizeNameIndex(prizeNames, getBonusName(bonusWin))] + '</td>');
							r.push('</tr>');
							r.push('<tr>');
							r.push('<td>' + getTranslationByName("bonusMultiplier", translations) + ' - ' + multiplierCount + 'x' + '</td>');
							r.push('</tr>');
							r.push('<tr>');
							r.push('<td>' + getTranslationByName("totalBonusWins", translations) + ' - ' + convertedPrizeValues[getPrizeNameIndex(prizeNames, getBonusName(bonusWin))] + ' x ' + multiplierCount + '</td>');
							r.push('</tr>');
							r.push('</table>');
							r.push('&nbsp;');
						}

						////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
						// !DEBUG OUTPUT TABLE
						if(debugFlag)
						{
							// DEBUG TABLE
							//////////////////////////////////////
							r.push('<table border="0" cellpadding="2" cellspacing="1" width="100%" class="gameDetailsTable">');
							for(var idx = 0; idx < debugFeed.length; ++idx)
 							{
								if(debugFeed[idx] == "")
									continue;
								r.push('<tr>');
 								r.push('<td class="tablebody">');
								r.push(debugFeed[idx]);
 								r.push('</td>');
	 							r.push('</tr>');
							}
							r.push('</table>');
						}
						return r.join('');
					}

					// Input: A list of Price Points and the available Prize Structures for the game as well as the wagered price point
					// Output: A string of the specific prize structure for the wagered price point
					function retrievePrizeTable(pricePoints, prizeStructures, wageredPricePoint)
					{
						var pricePointList = pricePoints.split(",");
						var prizeStructStrings = prizeStructures.split("|");

						for(var i = 0; i < pricePoints.length; ++i)
						{
							if(wageredPricePoint == pricePointList[i])
							{
								return prizeStructStrings[i];
							}
						}

						return "";
					}

					// Input: Json document string containing 'scenario' at root level.
					// Output: Scenario value.
					function getScenario(jsonContext)
					{
						// Parse json and retrieve scenario string.
						var jsObj = JSON.parse(jsonContext);
						var scenario = jsObj.scenario;

						// Trim null from scenario string.
						scenario = scenario.replace(/\0/g, '');

						return scenario;
					}

					// Input: Json document string containing 'amount' at root level.
					// Output: Price Point value.
					function getPricePoint(jsonContext)
					{
						// Parse json and retrieve price point amount
						var jsObj = JSON.parse(jsonContext);
						var pricePoint = jsObj.amount;

						return pricePoint;
					}

					// Input: "23,9,31|8:E,35:E,4:D,13:D,37:G,..."
					// Output: ["8", "35", "4", "13", ...] or ["E", "E", "D", "G", ...]
					function getOutcomeData(scenario)
					{
						var outcomePairs = scenario.split("|");
						var outcomeResult = [];
						for(var i = 0; i < 5; ++i)
						{
							outcomeResult.push(outcomePairs[i].split(","));
						}
						return outcomeResult;
					}

					function getBonusData(scenario)
					{
						var bonusDataString = scenario.split("|")[5];

						return bonusDataString;
					}

					// Input: 'X', 'E', or number (e.g. '23')
					// Output: translated text or number.
					function translateOutcomeNumber(outcomeNum, translations)
					{
						if (outcomeNum == 'W' || outcomeNum == 'X' || outcomeNum == 'Y' || outcomeNum == 'Z')
						{
							return getTranslationByName(outcomeNum, translations);
						}
						else
						{
							return outcomeNum;
						}
					}

					function getBonusName(bonusName)
					{
						if (bonusName == 'W')
						{
							return 'G'; // 'B1';
						}
						else if (bonusName == 'X')
						{
							return 'K'; // 'B2';
						}
						else if (bonusName == 'Y')
						{
							return 'M'; // 'B3';
						}
						else if (bonusName == 'Z')
						{
							return 'O'; // 'B4';
						}
					}

					// Input: "A,B,C,D,..." and "A"
					// Output: index number
					function getPrizeNameIndex(prizeNames, currPrize)
					{
						for(var i = 0; i < prizeNames.length; ++i)
						{
							if(prizeNames[i] == currPrize)
							{
								return i;
							}
						}
					}

					////////////////////////////////////////////////////////////////////////////////////////
					function registerDebugText(debugText)
					{
						debugFeed.push(debugText);
					}

					/////////////////////////////////////////////////////////////////////////////////////////
					function getTranslationByName(keyName, translationNodeSet)
					{
						var index = 1;
						while(index < translationNodeSet.item(0).getChildNodes().getLength())
						{
							var childNode = translationNodeSet.item(0).getChildNodes().item(index);
							
							if(childNode.name == "phrase" && childNode.getAttribute("key") == keyName)
							{
								registerDebugText("Child Node: " + childNode.name);
								return childNode.getAttribute("value");
							}
							
							index += 1;
						}
					}

					// Grab Wager Type
					// @param jsonContext String JSON results to parse and display.
					// @param translation Set of Translations for the game.
					function getType(jsonContext, translations)
					{
						// Parse json and retrieve wagerType string.
						var jsObj = JSON.parse(jsonContext);
						var wagerType = jsObj.wagerType;

						return getTranslationByName(wagerType, translations);
					}
					]]>
				</lxslt:script>
			</lxslt:component>

			<x:template match="root" mode="last">
				<table border="0" cellpadding="1" cellspacing="1" width="100%" class="gameDetailsTable">
					<tr>
						<td valign="top" class="subheader">
							<x:value-of select="//translation/phrase[@key='totalWager']/@value" />
							<x:value-of select="': '" />
							<x:call-template name="Utils.ApplyConversionByLocale">
								<x:with-param name="multi" select="/output/denom/percredit" />
								<x:with-param name="value" select="//ResultData/WagerOutcome[@name='Game.Total']/@amount" />
								<x:with-param name="code" select="/output/denom/currencycode" />
								<x:with-param name="locale" select="//translation/@language" />
							</x:call-template>
						</td>
					</tr>
					<tr>
						<td valign="top" class="subheader">
							<x:value-of select="//translation/phrase[@key='totalWins']/@value" />
							<x:value-of select="': '" />
							<x:call-template name="Utils.ApplyConversionByLocale">
								<x:with-param name="multi" select="/output/denom/percredit" />
								<x:with-param name="value" select="//ResultData/PrizeOutcome[@name='Game.Total']/@totalPay" />
								<x:with-param name="code" select="/output/denom/currencycode" />
								<x:with-param name="locale" select="//translation/@language" />
							</x:call-template>
						</td>
					</tr>
				</table>
			</x:template>

			<!-- TEMPLATE Match: digested/game -->
			<x:template match="//Outcome">
				<x:if test="OutcomeDetail/Stage = 'Scenario'">
					<x:call-template name="Scenario.Detail" />
				</x:if>
			</x:template>

			<!-- TEMPLATE Name: Scenario.Detail (base game) -->
			<x:template name="Scenario.Detail">
				<x:variable name="odeResponseJson" select="string(//ResultData/JSONOutcome[@name='ODEResponse']/text())" />
				<x:variable name="translations" select="lxslt:nodeset(//translation)" />
				<x:variable name="wageredPricePoint" select="string(//ResultData/WagerOutcome[@name='Game.Total']/@amount)" />
				<x:variable name="prizeTable" select="lxslt:nodeset(//lottery)" />

				<table border="0" cellpadding="0" cellspacing="0" width="100%" class="gameDetailsTable">
					<tr>
						<td class="tablebold" background="">
							<x:value-of select="//translation/phrase[@key='wagerType']/@value" />
							<x:value-of select="': '" />
							<x:value-of select="my-ext:getType($odeResponseJson, $translations)" disable-output-escaping="yes" />
						</td>
					</tr>
					<tr>
						<td class="tablebold" background="">
							<x:value-of select="//translation/phrase[@key='transactionId']/@value" />
							<x:value-of select="': '" />
							<x:value-of select="OutcomeDetail/RngTxnId" />
						</td>
					</tr>
				</table>
				<br />			
				
				<x:variable name="convertedPrizeValues">
					<x:apply-templates select="//lottery/prizetable/prize" mode="PrizeValue"/>
				</x:variable>

				<x:variable name="prizeNames">
					<x:apply-templates select="//lottery/prizetable/description" mode="PrizeDescriptions"/>
				</x:variable>


				<x:value-of select="my-ext:formatJson($odeResponseJson, $translations, $prizeTable, string($convertedPrizeValues), string($prizeNames))" disable-output-escaping="yes" />
			</x:template>

			<x:template match="prize" mode="PrizeValue">
					<x:text>|</x:text>
					<x:call-template name="Utils.ApplyConversionByLocale">
						<x:with-param name="multi" select="/output/denom/percredit" />
					<x:with-param name="value" select="text()" />
						<x:with-param name="code" select="/output/denom/currencycode" />
						<x:with-param name="locale" select="//translation/@language" />
					</x:call-template>
			</x:template>
			<x:template match="description" mode="PrizeDescriptions">
				<x:text>,</x:text>
				<x:value-of select="text()" />
			</x:template>

			<x:template match="text()" />
		</x:stylesheet>
	</xsl:template>

	<xsl:template name="TemplatesForResultXSL">
		<x:template match="@aClickCount">
			<clickcount>
				<x:value-of select="." />
			</clickcount>
		</x:template>
		<x:template match="*|@*|text()">
			<x:apply-templates />
		</x:template>
	</xsl:template>
</xsl:stylesheet>
