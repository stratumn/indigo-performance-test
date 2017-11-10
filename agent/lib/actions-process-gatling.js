module.exports = {
  events: {
    didSave: function(segment) {
      console.log('Segment ' + segment.meta.linkHash + ' was saved!');
    }
  },

  init: function(title) {
    if (!title) {
      return this.reject('a title is required');
    }

    this.state.title = title;
    this.state.messages = [];
    this.state.updatedAt = Date.now();
    this.meta.priority = 0;

    this.append();
  },

  addMessage: function(message) {
    if (!message) {
      return this.reject('a message is required');
    }

    this.state.messages.push({ message: message });
    this.state.updatedAt = Date.now();
    this.meta.priority++;

    this.append();
  }
};
