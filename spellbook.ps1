$url = "https://www.dnd5eapi.co/api/spells"
$headers = @{
    'Accept' = 'application/json'
}

function Get-SpellInfo($spell_index) {
    $spell_url = "$url/$spell_index"
    $resp_spell = Invoke-RestMethod -Uri $spell_url -Headers $headers -Method Get

    if ($resp_spell) {
        $spell_info = $resp_spell

        Write-Host ('-' * 40)
        Write-Host $spell_info.name
        Write-Host "Level $($spell_info.level) $($spell_info.school.name)"
        Write-Host ('-' * 40)
        Write-Host "URL: $($spell_url)"
        Write-Host "Description:"
        foreach ($line in $spell_info.desc) {
            Write-Host $line
        }
        Write-Host
        Write-Host "Spell range: $($spell_info.range)"
        Write-Host "Spell components:"
        foreach ($component in $spell_info.components) {
            switch ($component) {
                'V' { Write-Host '- Verbal' }
                'S' { Write-Host '- Somatic' }
                'M' { Write-Host "- Material: $($spell_info.material)" }
                default { Write-Host }
            }
        }
        if ($spell_info.PSObject.Properties['area_of_effect']) {
            Write-Host "AOE: $($spell_info.area_of_effect.type) $($spell_info.area_of_effect.size)ft"
        }
        Write-Host "Can cast as ritual spell: $($spell_info.ritual)"
        Write-Host "Spell duration: $($spell_info.duration)"
        Write-Host "Requires concentration: $($spell_info.concentration)"
        Write-Host "Casting time: $($spell_info.casting_time)"

        if ($spell_info.PSObject.Properties['attack_type']) {
            Write-Host "Type of attack: $($spell_info.attack_type)"
        }
        if ($spell_info.PSObject.Properties['damage']) {
            Write-Host "Damage type: $($spell_info.damage.damage_type.name)"
            Write-Host "Damage at slot level:"
            foreach ($slot_level in $spell_info.damage.damage_at_slot_level.PSObject.Properties) {
                Write-Host "- $($slot_level.Name): $($slot_level.Value)"
            }
        }
        Write-Host "Available classes:"
        foreach ($class in $spell_info.classes) {
            Write-Host "- $($class.name)"
        }
        if ($spell_info.PSObject.Properties['subclasses']) {
            Write-Host "Subclasses:"
            foreach ($subclass in $spell_info.subclasses) {
                Write-Host "- $($subclass.name)"
            }
        }
        Write-Host
        Write-Host
    } else {
        Write-Error "No results returned!"
    }
}

# Example usage
Get-SpellInfo "acid-arrow"
