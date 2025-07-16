-- Ajouter la colonne event_time à la table events
ALTER TABLE events ADD COLUMN event_time TIME AFTER event_date; 