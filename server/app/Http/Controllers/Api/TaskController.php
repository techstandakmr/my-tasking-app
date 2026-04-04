<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Task;
use App\Http\Requests\TaskRequest;

class TaskController extends Controller
{
    // Get all tasks of authenticated user
    public function index(Request $request)
    {
        return $request->user()->tasks;
    }

    // Create new task
    public function store(TaskRequest $request)
    {
        $task =  $request->user()->tasks()->create($request->validated());
        return response()->json([
            'message' => 'Task created successfully',
            'task' => $task
        ], 201);
    }

    // Get single task
    public function show(Request $request, Task $task)
    {
        $this->authorizeTask($request, $task); // check ownership
        return $task;
    }

    // Update task
    public function update(TaskRequest $request, Task $task)
    {
        $this->authorizeTask($request, $task); // check ownership
        $task->update($request->validated());
        return response()->json([
            'message' => 'Task updated successfully',
            'task' => $task
        ]);
    }

    // Delete task
    public function destroy(Request $request, Task $task)
    {
        $this->authorizeTask($request, $task); // check ownership
        $task->delete();
        return response()->json([
            'message' => 'Task deleted successfully'
        ]);
    }

    // Ensure task belongs to logged-in user
    private function authorizeTask(Request $request, Task $task)
    {
        if ($task->user_id !== $request->user()->id) {
            abort(403, 'Unauthorized');
        }
    }
}