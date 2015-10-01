#!/usr/bin/awk -f

/^<!-- !CSS .* -->$/ {
    print("<style type=\"text/css\">")
    system("cat "$3);
    print("</style>");
    next;
}

/^<!-- !JS .* -->$/ {
    print("<script type=\"text/javascript\">");
    system("cat "$3);
    print("</script>");
    next;
}

{ print }
