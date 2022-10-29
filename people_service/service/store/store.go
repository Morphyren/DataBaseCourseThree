package store

import (
	"context"
	"database/sql"
	"fmt"
	"os"
	"strconv"

	"github.com/golang-migrate/migrate/v4"
	"github.com/golang-migrate/migrate/v4/database/postgres"
	_ "github.com/golang-migrate/migrate/v4/source/file"
	"github.com/jackc/pgx/v4"
	_ "github.com/lib/pq"
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

	//migrations
	db, err := sql.Open("postgres", connString)
	if err != nil {
		panic(err)
	}
	defer db.Close()

	driver, err := postgres.WithInstance(db, &postgres.Config{})
	if err != nil {
		panic(err)
	}

	m, err := migrate.NewWithDatabaseInstance("file:../../migrations/", "postgres", driver)
	if err != nil {
		panic(err)
	}

	m.Up()

	return &Store{
		conn: conn,
	}
}

func (s *Store) ListPeople() ([]People, error) {

	//count rows for slice
	var cnty int
	err := s.conn.QueryRow(context.Background(), `SELECT COUNT(*) FROM people`).Scan(&cnty)
	if err != nil {
		fmt.Fprintf(os.Stderr, "some problem: %v\n", err)
		return nil, nil
	}

	//data recording
	users := make([]People, 0, cnty)

	//query
	rows, err := s.conn.Query(context.Background(), `
	SELECT ID, Name
	FROM people
	`)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Query failed: %v \n", err)
		return nil, nil
	}
	defer rows.Close()

	//handle rows
	for rows.Next() {
		var id string
		var name string

		if err := rows.Scan(&id, &name); err != nil {
			fmt.Fprintf(os.Stderr, "Rows scan failed: %v \n", err)
			return nil, nil
		}
		// ID in table "people" have type int
		n, err := strconv.Atoi(id)
		if err != nil {
			fmt.Fprintf(os.Stderr, "not an integer: %v \n", err)
			return nil, nil
		}

		// add normalized data
		users = append(users, People{
			ID:   n,
			Name: name,
		})
	}

	//last check for error
	if rows.Err() != nil {
		fmt.Fprintf(os.Stderr, "Query failed: %v \n", err)
		return nil, nil
	}

	return users, nil
}

func (s *Store) GetPeopleByID(id string) (People, error) {
	//id
	var i string
	//name
	var n string

	//scan id and name to i, n
	err := s.conn.QueryRow(context.Background(), `
	SELECT ID, Name
	FROM people
	WHERE ID = ?`, id).Scan(&i, &n)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Query failed: %v \n", err)
		return People{}, nil
	}

	// ID in table "people" have type int
	nt, err := strconv.Atoi(i)
	if err != nil {
		fmt.Fprintf(os.Stderr, "not an integer: %v \n", err)
		return People{}, nil
	}

	//result by id
	var result = People{
		ID:   nt,
		Name: n,
	}

	return result, nil
}
