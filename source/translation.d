module translation;

struct Translation {
    string category;
    string source;
    string target;

    this(string[] data) {
        this.category = remove_unneeded_info(data[1]);
        this.source   = remove_unneeded_info(data[2]);
        this.target   = remove_unneeded_info(data[3]);
    }

    private string remove_unneeded_info(string translated_string) {
        import std.string : strip;
        import std.array : join, split;
        import std.conv : to;
        import std.algorithm : endsWith;

        if (translated_string.endsWith(".")) {
            auto temp_arr = translated_string.split(" ");

            translated_string = temp_arr[0 .. $ - 1].join(" ");
        }

        return translated_string.strip();
    }
}

struct Translation_Table {
    string source_lang;
    string target_lang;
    Translation[] data;
    bool isOtherTerm;

    import arsd.dom : Element;
    this(Element table_html) {
        import std.algorithm : map, filter;
        import std.string : strip;
        import std.array : array;

        foreach (table_row; table_html.querySelectorAll("tr")) {
            auto table_headers =
                table_row
                .querySelectorAll("th")
                .map!(
                    d => strip(d.innerText)
                ).array;

            if (table_headers.length > 0) {
                this.source_lang = table_headers[2];
                this.target_lang = table_headers[3];
            }
            else {
                auto table_data =
                    table_row
                    .querySelectorAll("td")
                    .map!(
                        d => strip(d.innerText)
                    ).array;

                if (table_data.length > 2) { // Filter out the unimportant noise.
                    this.data ~= Translation(table_data);
                }
            }
        }

        this.isOtherTerm = false;
        string temp = this.data[0].source;
        foreach (tr; this.data) {
            if (tr.source != temp) {
                this.isOtherTerm = true;
                break;
            }
        }
    }

    string toString() {
        string end = this.isOtherTerm ? " (Other):" : ":";
        return this.source_lang ~ " -> " ~ this.target_lang ~ end;
    }
}
