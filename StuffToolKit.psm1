# Define the shared Naviga API Config for the entire module.
$script:NavigaConfigPath = "C:\Work\StuffToolKit\configs\NavigaAuth.xml"

# Define the shared character replacement map for the entire module.
# All functions loaded below will have access to this variable.
$script:replacementMap = @{
        ([char]0x2018) = "'"    # ‘ Left single quotation mark
        ([char]0x2019) = "'"    # ’ Right single quotation mark
        ([char]0x201A) = ","    # ‚ Single low-9 quotation mark
        ([char]0x201B) = "'"    # ‛ Single high-reversed-9 quotation mark
        ([char]0x201C) = '"'    # “ Left double quotation mark
        ([char]0x201D) = '"'    # ” Right double quotation mark
        ([char]0x201E) = ","    # „ Double low-9 quotation mark

        # Spaces and invisible separators
        ([char]0x2000) = " "    # En quad
        ([char]0x2001) = " "    # Em quad
        ([char]0x2002) = " "    # En space
        ([char]0x2003) = " "    # Em space
        ([char]0x2004) = " "    # Three-per-em space
        ([char]0x2005) = " "    # Four-per-em space
        ([char]0x2006) = " "    # Six-per-em space
        ([char]0x2007) = " "    # Figure space
        ([char]0x2008) = " "    # Punctuation space
        ([char]0x2009) = " "    # Thin space
        ([char]0x200A) = " "    # Hair space
        ([char]0x200B) = " "    # Zero width space
        ([char]0x200C) = " "    # Zero width non-joiner
        ([char]0x200D) = " "    # Zero width joiner

        # Dashes
        ([char]0x2010) = "-"    # ‐ Hyphen
        ([char]0x2011) = "-"    # - Non-breaking hyphen
        ([char]0x2012) = "-"    # ‒ Figure dash
        ([char]0x2013) = "-"    # – En dash
        ([char]0x2014) = "-"    # — Em dash
        ([char]0x2015) = "-"    # ― Horizontal bar

        # Ellipsis and fraction slash
        ([char]0x2026) = "..."  # … Ellipsis
        ([char]0x2044) = "/"    # ⁄ Fraction slash

        # Bullets and symbols
        ([char]0x2022) = "-"    # • Bullet
        ([char]0x2023) = "-"    # ‣ Triangular bullet
        ([char]0x2020) = "*"    # † Dagger
        ([char]0x2021) = "*"    # ‡ Double dagger

        # Trademark and copyright
        ([char]0x00A9) = ""     # ©
        ([char]0x00AE) = ""     # ®
        ([char]0x2122) = ""     # ™
    }

$script:macronMap = @{
    ([string]([char]0x00C5) + [char]0x0152) = "Ō"
}
    

# Auto-import all functions from the 'functions' subfolder.
# They will be able to see the $script:replacementMap defined above.
Get-ChildItem -Path "$PSScriptRoot/functions" -Filter *.ps1 | ForEach-Object {
    . $_.FullName
}