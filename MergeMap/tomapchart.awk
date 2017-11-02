BEGIN { s = 0 }
{
	if ($1 == "group") {
		if (s != 0) {
			printf ";ENDOFGROUP\n\n"
		}
		printf "%s\n", $0
		printf ";BEGINOFGROUP\n"
		s = 1
	}
	else {
		split ($1, marker, ",")
		for (i in marker) {
			printf "%s\t%s\n", marker[i], $2
		}
	}
}
END { printf ";ENDOFGROUP\n" }
