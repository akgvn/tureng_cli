module translation;

import std.array : appender;
import std.stdio;
import arsd.dom : Element;

class Translation
{
    public string category;
    public string source;
    public string target;

    this(string[] data)
    {
        this.category = data[1];
        this.source = data[2];
        this.target = reducer(data[3]);
    }

    override string toString()
    {
        return "(" ~ this.category ~ ") " ~ this.source ~ ": " ~ target;
    }
}

class Translation_Table
{
    public string source_lang;
    public string target_lang;
    public Translation[] data;
    public bool isOtherTerm;

    this(Element table_html)
    {
        import std.algorithm : map, filter;
        import std.string : strip;
        import std.array : array;

        foreach (table_row; table_html.querySelectorAll("tr"))
        {
            auto table_headers = table_row.querySelectorAll("th")
                .map!(d => strip(d.innerText)).array;

            if (table_headers.array() != [])
            {
                this.source_lang = table_headers[2];
                this.target_lang = table_headers[3];
            }
            else
            {
                auto table_data = table_row.querySelectorAll("td")
                    .map!(d => strip(d.innerText)).array;

                if (table_data.length > 2) // Filter out the unimportant noise.
                {
                    this.data ~= new Translation(table_data);
                }
            }
        }

        this.isOtherTerm = false;
        string temp = this.data[0].source;
        foreach (tr; this.data)
        {
            if (tr.source != temp)
            {
                this.isOtherTerm = true;
            }
        }
    }

    override string toString()
    {
        string end = this.isOtherTerm ? " (Other):" : ":";

        return this.source_lang ~ " -> " ~ this.target_lang ~ end;
    }
}

string reducer(string st)
{
    import std.string : strip;
    import std.conv : to;
    import std.algorithm : endsWith;

    string temp = strip(to!string(st));

    if (temp.endsWith("."))
    {
        temp = strip(temp[0 .. $ - 2]);
    }

    return temp;
}
