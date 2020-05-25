#!/usr/bin/env python3
"""The app is created here along with all the instances of its classes"""
import sqlite3
import falcon
import ujson

api = falcon.API()


class RandomThree:
    """Class for the route that returns 3 random stories from the database"""

    def __init__(self):
        self.db = "file:data/inbrain.db?mode=ro"

    def select_random_three(self):
        """
        Retrieves 3 random stories from the stories table.
        Uses a special function to return the data as a dict rather than a tuple

        Returns:
        --------
        result: dict
            {"results": List[dict]}

        """
        with sqlite3.connect(self.db, uri=True) as conn:
            dict_factory = lambda c, r: dict(zip([col[0] for col in c.description], r))
            conn.row_factory = dict_factory

            result = conn.execute(
                "SELECT * FROM stories ORDER BY RANDOM() LIMIT 3"
            ).fetchall()
        return result

    def on_get(self, req, resp):
        """creates the response for the GET request.
        Parameters
        ----------

        Returns
        -------
        resp: Falcon response object
            the reponse object body attribute contains the result of the random_three function
        """
        results = self.select_random_three()
        resp.set_header("Access-Control-Allow-Origin", "*")
        resp.status = falcon.HTTP_200
        body = {"results": results}
        resp.body = ujson.dumps(body)


random_three = RandomThree()

api.add_route("/random_three", random_three)
