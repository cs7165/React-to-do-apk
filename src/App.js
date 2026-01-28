import React, { useState, useEffect } from 'react';
import TodoForm from './components/TodoForm';
import TodoList from './components/TodoList';
import History from './components/History';
import './App.css';

function App() {
  const [todos, setTodos] = useState([]);
  const [history, setHistory] = useState([]);
  const [activeTab, setActiveTab] = useState('today');

  // Load data from localStorage on mount
  useEffect(() => {
    const savedTodos = JSON.parse(localStorage.getItem('todos')) || [];
    const savedHistory = JSON.parse(localStorage.getItem('history')) || [];
    setTodos(savedTodos);
    setHistory(savedHistory);
  }, []);

  // Save todos to localStorage
  useEffect(() => {
    localStorage.setItem('todos', JSON.stringify(todos));
  }, [todos]);

  // Save history to localStorage
  useEffect(() => {
    localStorage.setItem('history', JSON.stringify(history));
  }, [history]);

  const addTodo = (text) => {
    const newTodo = {
      id: Date.now(),
      text: text,
      completed: false,
      createdAt: new Date().toLocaleDateString()
    };
    setTodos([newTodo, ...todos]);
  };

  const toggleTodo = (id) => {
    setTodos(todos.map(todo =>
      todo.id === id ? { ...todo, completed: !todo.completed } : todo
    ));
  };

  const deleteTodo = (id) => {
    const todo = todos.find(t => t.id === id);
    if (todo) {
      setHistory([...history, { ...todo, deletedAt: new Date().toLocaleDateString() }]);
    }
    setTodos(todos.filter(todo => todo.id !== id));
  };

  const clearCompleted = () => {
    const completed = todos.filter(t => t.completed);
    completed.forEach(todo => {
      setHistory(prev => [...prev, { ...todo, deletedAt: new Date().toLocaleDateString() }]);
    });
    setTodos(todos.filter(todo => !todo.completed));
  };

  return (
    <div className="app-container">
      <header className="app-header">
        <h1>📋 Daily To-Do List</h1>
        <p>Keep track of your daily tasks</p>
      </header>

      <div className="tabs">
        <button 
          className={`tab-btn ${activeTab === 'today' ? 'active' : ''}`}
          onClick={() => setActiveTab('today')}
        >
          Today's Tasks
        </button>
        <button 
          className={`tab-btn ${activeTab === 'history' ? 'active' : ''}`}
          onClick={() => setActiveTab('history')}
        >
          History
        </button>
      </div>

      <main className="app-main">
        {activeTab === 'today' ? (
          <div className="today-section">
            <TodoForm onAddTodo={addTodo} />
            <TodoList 
              todos={todos} 
              onToggleTodo={toggleTodo}
              onDeleteTodo={deleteTodo}
            />
            {todos.length > 0 && (
              <button className="clear-btn" onClick={clearCompleted}>
                Clear Completed
              </button>
            )}
          </div>
        ) : (
          <History history={history} />
        )}
      </main>
    </div>
  );
}

export default App;
