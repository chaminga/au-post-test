/**
 * @description       : 
 * @author            : Chaminga Dissanayake
 * @group             : 
 * @last modified on  : 02-20-2021
 * @last modified by  : Chaminga Dissanayake
 * Modifications Log 
 * Ver   Date         Author                 Modification
 * 1.0   02-19-2021   Chaminga Dissanayake   Initial Version
**/
trigger CaseTrigger on Case (after update) {
    new CaseTriggerHandler().run();
}