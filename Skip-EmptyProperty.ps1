filter Skip-EmptyProperty {
   $hashtable = [Ordered]@{}
   $properties = ($_ | Get-Member -MemberType CodeProperty,NoteProperty,Property,ScriptProperty).Name
   foreach ($property in $properties) {
      try {
        if ($_.${property}.ToString()) {
            $hashtable[$property]=$_.${property}
        }
      } catch {}
   }
   [PSCustomObject]$hashtable
} 