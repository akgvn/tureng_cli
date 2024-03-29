import std.stdio : write, writeln;
import std.net.curl : get, HTTP;
import arsd.dom : Document;
import std.uri : encode;
import translation;

void main(string[] args) {
    string word;

    if (args.length < 2) {
        writeln("Run this with at least one argument! Pass -a as the second argument for the abridged version.");
        return;
    }
    word = args[1];
    
    const abridged = args.length == 3 && args[2] == "-a";

    auto html_document = new Document(get_page_html(word));
    auto ttables = get_result_tables(html_document);
    print_to_command_line(ttables, abridged);
}

void print_to_command_line(Translation_Table[] ttables, bool abridged) {
    foreach (t; ttables) {
        bool other = t.isOtherTerm;
        if (abridged && other) break;

        write("# ", t.toString());

        string category = "";
        if (!other) {
            foreach (d; t.data) {
                if (d.category == category) {
                    write(", " ~ d.target);
                } else {
                    category = d.category;
                    write("\n" ~ d.category ~ ": " ~ d.target);
                }
            }
        } else {
            foreach (d; t.data) {
                if (d.category == category) {
                    write("\n\t" ~ d.source ~ " : " ~ d.target);
                } else {
                    category = d.category;
                    write("\n" ~ d.category ~ " => \n\t" ~ d.source ~ " : " ~ d.target);
                }
            }
        }
        writeln();
        writeln();
    }

}

string get_page_html(string word) {
    import std.conv : to;
    const user_agent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:105.0) Gecko/20100101 Firefox/105.0";
    const address = "https://tureng.com/en/turkish-english/" ~ word;
    const encoded_address = address.encode();
    
    auto http = HTTP();
    http.setUserAgent(user_agent);
    http.method = HTTP.Method.get;
    http.url = encoded_address;
    char[] buffer;

    http.onReceive = (ubyte[] data) {
        buffer ~= data;
        return data.length;
    };
    http.perform();

    return to!string(buffer);
}

Translation_Table[] get_result_tables(Document doc) {
    auto tables = doc.querySelectorAll("#englishResultsTable");

    auto tt = new Translation_Table[tables.length];

    foreach (idx, table; tables) {
        tt[idx] = Translation_Table(table);
    }

    return tt;
}
