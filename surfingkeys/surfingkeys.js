// surfingkeys.js

const hintsCss = `
font-size: 12pt; 
font-family: 'JetBrains Mono NL', 'Cascadia Code', 'Helvetica Neue', Helvetica, Arial, sans-serif; 
border: 1px; 
color: #f6c177 !important; 
background: #31748f; 
background-color: #191724
`;

api.Hints.style(hintsCss);
api.Hints.style(hintsCss, "text");

settings.theme = `
.sk_theme {
    background: #191724;
    color: #e0def4;
}

.sk_theme input {
    color: #e0def4;
}

.sk_theme .url {
    color: #c4a7e7;
}

.sk_theme .annotation {
    color: #ebbcba;
}

.sk_theme kbd {
    background: #26233a;
    color: #e0def4;
    font-size: 15px;
}

.sk_theme .frame {
    background: #1f1d2e;
}

.sk_theme .omnibar_highlight {
    color: #eb6f92;
}

.sk_theme .omnibar_folder {
    color: #e0def4;
}

.sk_theme .omnibar_timestamp {
    color: #9ccfd8;
}

.sk_theme .omnibar_visitcount {
    color: #9ccfd8;
}

.sk_theme .prompt, .sk_theme .resultPage {
    color: #e0def4;
}

.sk_theme .feature_name {
    color: #e0def4;
}

.sk_theme .separator {
    color: #f6c177;
}

body {
    margin: 0;
    font-family: "JetBrains Mono NL", "Cascadia Code", "Helvetica Neue", Helvetica, Arial, sans-serif;
    font-size: 15px;
}

/* Add additional styles here following the same pattern */
`;

// Additional JavaScript logic can be added below
