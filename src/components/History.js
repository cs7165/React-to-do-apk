import React from 'react';
import '../styles/History.css';

function History({ history }) {
  if (history.length === 0) {
    return (
      <div className="history-container">
        <p className="empty-message">No history yet. Complete some tasks to see them here! 📚</p>
      </div>
    );
  }

  // Group history by date
  const groupedByDate = history.reduce((acc, item) => {
    const date = item.deletedAt || item.createdAt;
    if (!acc[date]) {
      acc[date] = [];
    }
    acc[date].push(item);
    return acc;
  }, {});

  return (
    <div className="history-container">
      <h2>Task History</h2>
      {Object.entries(groupedByDate).map(([date, items]) => (
        <div key={date} className="history-group">
          <h3 className="history-date">{date}</h3>
          <ul className="history-list">
            {items.map(item => (
              <li key={item.id} className="history-item">
                <span className="history-status">
                  {item.completed ? '✅' : '❌'}
                </span>
                <span className="history-text">{item.text}</span>
              </li>
            ))}
          </ul>
        </div>
      ))}
    </div>
  );
}

export default History;
