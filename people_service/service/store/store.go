package store

import (
	"fmt"
	"os"
	"strconv"

	"context"

	"github.com/jackc/pgx/v4"

	"database/sql"

	_ "github.com/lib/pq"

	"github.com/golang-migrate/migrate/v4"

	"github.com/golang-migrate/migrate/v4/database/postgres"

	_ "github.com/golang-migrate/migrate/v4/source/file"
)

type Store struct {
	conn *pgx.Conn
}

type People struct {
	ID   int
	Name string
}

// NewStore creates new database connection
func NewStore(connString string) *Store {
	conn, err := pgx.Connect(context.Background(), connString)
	if err != nil {
		panic(err)
	}

	db, err := sql.Open("postgres", connString)
	if err != nil {
		panic(err)
	}

	driver, err := postgres.WithInstance(db, &postgres.Config{})
	if err != nil {
		panic(err)
	}

	m, err := migrate.NewWithDatabaseInstance("file:../../migrations/1_initial.up.sql", "postgres", driver)
	if err != nil {
		panic(err)
	}

	m.Up()

	return &Store{
		conn: conn,
	}
}

func (s *Store) ListPeople() ([]People, error) {

	var cnty int

	count, err := s.conn.Query(context.Background(), `
	SELECT COUNT(*)
	FROM people
	`)
	if err != nil {
		fmt.Fprintf(os.Stderr, "some problem: %v \n", err)
		return nil, nil
	}
	defer count.Close()

	if err := count.Scan(&cnty); err != nil {
		fmt.Fprintf(os.Stderr, "Some troubles: %v \n", err)
		return nil, nil
	}

	rows, err := s.conn.Query(context.Background(), `
	SELECT *
	FROM people
	`)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Query failed: %v \n", err)
		return nil, nil
	}

	users := make([]People, 0, cnty)
	defer rows.Close()

	for rows.Next() {
		var id string
		var name string

		if err := rows.Scan(&id, &name); err != nil {
			fmt.Fprintf(os.Stderr, "Rows scan failed: %v \n", err)
			return nil, nil
		}

		n, err := strconv.Atoi(id)
		if err != nil {
			fmt.Fprintf(os.Stderr, "not an integer: %v \n", err)
			return nil, nil
		}

		users = append(users, People{
			ID:   n,
			Name: name,
		})
	}

	if rows.Err() != nil {
		fmt.Fprintf(os.Stderr, "Query failed: %v \n", err)
		return nil, nil
	}

	return users, err
}

func (s *Store) GetPeopleByID(id string) (People, error) {
	return People{}, nil
}
