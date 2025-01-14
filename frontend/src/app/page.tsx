"use client"
import { useState } from "react";
import { ethers } from "ethers";

export default function Home() {
  const [tasks, setTasks] = useState<string[]>([]);
  const [newTask, setNewTask] = useState<string>("");
  const [loading, setLoading] = useState<boolean>(false);

  // Function to handle adding a task
  const addTask = async () => {
    if (!newTask.trim()) return alert("Task cannot be empty!");
    setLoading(true);
    try {
      // Replace with your contract interaction logic
      // For example: await contract.addTask(newTask);
      setTasks((prevTasks) => [...prevTasks, newTask]);
      setNewTask("");
    } catch (error) {
      console.error(error);
      alert("Failed to add task!");
    } finally {
      setLoading(false);
    }
  };

  // Function to simulate fetching tasks from contract
  const fetchTasks = async () => {
    setLoading(true);
    try {
      // Replace with contract call logic to fetch tasks
      // Example: const fetchedTasks = await contract.getTasks();
      const fetchedTasks = ["Example Task 1", "Example Task 2"];
      setTasks(fetchedTasks);
    } catch (error) {
      console.error(error);
      alert("Failed to fetch tasks!");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-gray-100 p-8">
      <h1 className="text-2xl font-bold text-center mb-8">Task Manager</h1>
      <div className="max-w-lg mx-auto bg-white p-6 rounded shadow">
        {/* Input for adding a new task */}
        <div className="mb-4">
          <input
            type="text"
            placeholder="Enter new task"
            value={newTask}
            onChange={(e) => setNewTask(e.target.value)}
            className="w-full px-4 py-2 border border-gray-300 rounded focus:outline-none focus:ring-2 focus:ring-blue-500"
          />
          <button
            onClick={addTask}
            disabled={loading}
            className="mt-2 w-full px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600 disabled:bg-gray-400"
          >
            {loading ? "Adding..." : "Add Task"}
          </button>
        </div>

        {/* Fetch tasks button */}
        <div className="mb-4">
          <button
            onClick={fetchTasks}
            disabled={loading}
            className="w-full px-4 py-2 bg-green-500 text-white rounded hover:bg-green-600 disabled:bg-gray-400"
          >
            {loading ? "Loading..." : "Fetch Tasks"}
          </button>
        </div>

        {/* List of tasks */}
        <div>
          <h2 className="text-xl font-semibold mb-2">Your Tasks</h2>
          {tasks.length === 0 ? (
            <p className="text-gray-500">No tasks yet. Add a new one!</p>
          ) : (
            <ul className="list-disc pl-5 space-y-2">
              {tasks.map((task, index) => (
                <li key={index} className="text-gray-800">
                  {task}
                </li>
              ))}
            </ul>
          )}
        </div>
      </div>
    </div>
  );
}
