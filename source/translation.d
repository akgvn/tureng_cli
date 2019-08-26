module translation;

class Translation {
    public string type;
    public string source;
    public string target;

    this(string[] data) {
        this.type = data[1];
        this.source = data[2];
        this.target = data[3];
    }

    override string toString() {
        return "(" ~ this.type ~ ") " ~ this.source ~ ": " ~ target;
    }
}

class Translation_Table {
    public string source_lang;
    public string target_lang;
    public Translation[] data;
}