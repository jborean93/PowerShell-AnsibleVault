# Copyright: (c) 2018, Jordan Borean (@jborean93) <jborean93@gmail.com>
# MIT License (see LICENSE or https://opensource.org/licenses/MIT)

Function Split-Byte {
    <#
    .SYNOPSIS
    Splits a byte array based on the character specified.

    .DESCRIPTION
    Takes in a byte array and splits into an ArrayList based on the character
    specified by Char.

    .PARAMETER Value
    [byte[]] The byte array to split.

    .PARAMETER Char
    [char] The char to split the byte array with.

    .PARAMETER MaxSplit
    [int] If specified, this is maximum number of splits that will occur.

    .OUTPUTS
    [System.Collections.ArrayList] The array list that contains each split.

    .EXAMPLE
    Split-Bytes -Value -Char ([char]"`n")

    Split-Bytes -Value $byte_array -Char ([char]"a") -MaxSplit 2

    .NOTES
    The MaxSplit parameter is the number of times a split will occur and not
    number of entries in the returned ArrayList. For example -MaxSplit of 2 but
    the char appears more than 2 times, the output object will contain 3 entries.
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.ArrayList])]
    param(
        [Parameter(Mandatory=$true)] [byte[]]$Value,
        [Parameter(Mandatory=$true)] [char]$Char,
        [Parameter()] $MaxSplit = $null
    )
    $previous_index = 0
    $byte_split = New-Object -TypeName System.Collections.ArrayList
    while ($true) {
        if (($null -ne $MaxSplit) -and ($byte_split.Count -ge $MaxSplit)) {
            $new_entry = New-Object -TypeName byte[] -ArgumentList ($Value.Length - $previous_index)
            [System.Array]::Copy($Value, $previous_index, $new_entry, 0, $Value.Length - $previous_index)
            $byte_split.Add($new_entry) > $null
            break
        }

        $newline_index = [System.Array]::IndexOf($Value, [byte]$Char, $previous_index)
        if ($newline_index -eq -1) {
            $new_entry = New-Object -TypeName byte[] -ArgumentList ($Value.Length - $previous_index)
            [System.Array]::Copy($Value, $previous_index, $new_entry, 0, $Value.Length - $previous_index)
            $byte_split.Add($new_entry) > $null
            break
        }

        $new_entry = New-Object -TypeName byte[] -ArgumentList ($newline_index - $previous_index)
        [System.Array]::Copy($Value, $previous_index, $new_entry, 0, $newline_index - $previous_index)
        $byte_split.Add($new_entry) > $null
        $previous_index = $newline_index + 1
    }

    # remove any empty arrays (2 chars were next to each other)
    for ($i = 0; $i -lt $byte_split.Count; $i++) {
        if ($byte_split[$i].Count -eq 0) {
            $byte_split.RemoveAt($i) > $null
        }
    }

    return $byte_split
}