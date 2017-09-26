{**
 * plugins/generic/funding/templates/editFunderForm.tpl
 *
 * Copyright (c) 2014-2017 Simon Fraser University
 * Copyright (c) 2003-2017 John Willinsky
 * Distributed under the GNU GPL v2. For full terms see the file docs/COPYING.
 *
 * Form for editing a funder item
 *}

<script>
	$(function() {ldelim}
		// Attach the form handler.
		$('#funderForm').pkpHandler('$.pkp.controllers.form.AjaxFormHandler');
	{rdelim});

	$(document).ready(function(){ldelim}

		function addSubsidiaryOptions(descendants, names) {ldelim}
			var selectElement = document.getElementById("subsidiaryOption");
			descendants.sort(function(a, b) {ldelim}
				return names[a].localeCompare(names[b]);
			{rdelim});
			$.each(descendants, function(index, value) {ldelim}
				var option = document.createElement("option");
				option.text = names[value];
				option.value = names[value] + '[' + value + ']';
				selectElement.add(option);
			{rdelim});
		{rdelim};

		function removeSubsidiaryOptions() {ldelim}
			var selectElement = document.getElementById("subsidiaryOption");
			$("#subsidiaryOption option[value!='']").remove();
		{rdelim};

		$(".funderNameIdentification").tagit({ldelim}
			fieldName: 'funderNameIdentification[]',
			allowSpaces: true,
			tagLimit: 1,
			tagSource: function(search, response){ldelim}
				$.ajax({ldelim}
					url: 'http://api.crossref.org/funders',
					dataType: 'json',
					cache: true,
					data: {ldelim}
						query: search.term + '*'
					{rdelim},
					success:
						function( data ) {ldelim}
							var output = data.message.items;
							response($.map(output, function(item) {ldelim}
								return {ldelim}
									label: item.name + ' [' + item['alt-names'] + ']',
									value: item.name + ' [' + item.uri + ']'
								{rdelim}
							{rdelim}));
						{rdelim}
				{rdelim});
			{rdelim},
			afterTagAdded: function(event, ui) {ldelim}
				$.ajax({ldelim}
					url: 'http://search.crossref.org/funders?descendants=true',
					dataType: 'json',
					cache: true,
					data: {ldelim}
						q: ui.tagLabel + '*'
					{rdelim},
					success:
						function( data ) {ldelim}
							if (data.length == 1) {ldelim}
								if (data[0]['descendants'].length > 1) {ldelim}
									addSubsidiaryOptions(data[0]['descendants'], data[0]['descendant_names']);
									$("#subsidiarySelect").show();
								{rdelim}
							{rdelim}
						{rdelim}	
				{rdelim});
			{rdelim},
			afterTagRemoved: function(event, ui) {ldelim}
				removeSubsidiaryOptions();
				$("#subsidiarySelect").hide();
			{rdelim}
		{rdelim});

		$(".funderGrants").tagit({ldelim}
			fieldName: 'funderGrants[]',
			allowSpaces: true,
			singleField: true,
			singleFieldDelimiter: ";",
		{rdelim});

    {rdelim});
</script>

{url|assign:actionUrl router=$smarty.const.ROUTE_COMPONENT component="plugins.generic.funding.controllers.grid.FunderGridHandler" op="updateFunder" submissionId=$submissionId escape=false}
<form class="pkp_form" id="funderForm" method="post" action="{$actionUrl}">
	{csrf}
	{if $funderId}
		<input type="hidden" name="funderId" value="{$funderId|escape}" />
	{/if}
	{fbvFormArea id="funderFormArea" class="border"}
		{fbvFormSection}
			{fbvElement type="hidden" class="funderNameIdentification" label="plugins.generic.funding.funderNameIdentification" id="funderNameIdentification" value=$funderNameIdentification maxlength="255" inline=true size=$fbvStyles.size.LARGE}
			<span>{translate key="plugins.generic.funding.funderNameIdentification"}</span>
		{/fbvFormSection}
		<div name="subsidiarySelect" id="subsidiarySelect" class="section" style="display:none">
			{fbvElement type="select" name="subsidiaryOption" id="subsidiaryOption" from=$subsidiaryOptions size=$fbvStyles.size.LARGE translate=false}
			<span>{translate key="plugins.generic.funding.funderSubOrganization"}</span>
		</div>
		{fbvFormSection}
			{fbvElement type="hidden" class="funderGrants" label="plugins.generic.funding.funderGrants" id="funderGrants" value=$funderGrants maxlength="255" inline=true size=$fbvStyles.size.LARGE}
			<span>{translate key="plugins.generic.funding.funderGrants"}</span>
		{/fbvFormSection}				
	{/fbvFormArea}
	{fbvFormSection class="formButtons"}
		{assign var=buttonId value="submitFormButton"|concat:"-"|uniqid}
		{fbvElement type="submit" class="submitFormButton" id=$buttonId label="common.save"}
	{/fbvFormSection}
</form>
