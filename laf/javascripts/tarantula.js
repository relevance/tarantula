$(document).ready(function() {
	$(".tablesorter").tablesorter({
		sortColumn: 'name',			// Integer or String of the name of the column to sort by.
		sortClassAsc: 'headerSortUp',		// class name for ascending sorting action to header
		sortClassDesc: 'headerSortDown',	// class name for descending sorting action to header
		headerClass: 'header'			// class name for headers (th's)
	});
});

