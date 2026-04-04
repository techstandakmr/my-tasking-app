<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use App\Models\User;
class Task extends Model
{
    use HasFactory;
    protected $fillable = [
        "title",
        "description",
        "due_date",
        "stage",
        "priority"
    ];
    public function user()
    {
        return $this->belongsTo(User::class);
    }
}
