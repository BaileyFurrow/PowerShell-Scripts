
$Pieces = @{
    White = @{
        King   = [char]0x2654
        Queen  = [char]0x2655
        Rook   = [char]0x2656
        Bishop = [char]0x2657
        Knight = [char]0x2658
        Pawn   = [char]0x2659
    }
    Black = @{}
}
foreach ($piece in $Pieces.White.GetEnumerator()) {
    $Pieces.Black[$piece.Key] = [char]([int]$piece.Value + 6)
}

