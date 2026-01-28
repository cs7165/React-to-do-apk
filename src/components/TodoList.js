import React from 'react';
import '../styles/TodoList.css';

function TodoList({ todos, onToggleTodo, onDeleteTodo }) {
  return (
    <div className="todo-list">
      {todos.length === 0 ? (
        <p className="empty-message">No tasks yet. Add one to get started! 🚀</p>
      ) : (
        <ul>
          {todos.map(todo => (
            <li key={todo.id} className={`todo-item ${todo.completed ? 'completed' : ''}`}>
              <div className="todo-content">
                <input
                  type="checkbox"
                  checked={todo.completed}
                  onChange={() => onToggleTodo(todo.id)}
                  className="todo-checkbox"
                />
                <span className="todo-text">{todo.text}</span>
              </div>
              <div className="todo-meta">
                <small>{todo.createdAt}</small>
                <button
                  onClick={() => onDeleteTodo(todo.id)}
                  className="delete-btn"
                  title="Delete task"
                >
                  🗑️
                </button>
              </div>
            </li>
          ))}
        </ul>
      )}
    </div>
  );
}

export default TodoList;
