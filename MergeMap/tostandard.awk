{
	if ($1 == "group") {
		group = $2
	}
	else {
		split ($1, marker, ",")
		for (i in marker) {
			printf "%s\t%s\t%s\n", group, marker[i], $2
		}
	}
}
